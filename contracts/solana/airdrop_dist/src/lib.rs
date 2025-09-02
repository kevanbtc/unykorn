use anchor_lang::prelude::*;
use anchor_lang::solana_program::keccak;
use anchor_spl::{
    token::{self, Mint, Token, TokenAccount, Transfer},
    associated_token::AssociatedToken,
};

declare_id!("Fdrop11111111111111111111111111111111111111");

#[program]
pub mod airdrop_dist {
    use super::*;

    pub fn init(ctx: Context<Init>, root: [u8; 32]) -> Result<()> {
        let dist = &mut ctx.accounts.distributor;
        dist.root = root;
        Ok(())
    }

    pub fn claim(ctx: Context<Claim>, index: u64, amount: u64, proof: Vec<[u8; 32]>) -> Result<()> {
        let dist = &mut ctx.accounts.distributor;
        require!(!get_claimed(&dist.bitmap, index), AirdropError::AlreadyClaimed);

        let node = keccak::hashv(&[
            &index.to_le_bytes(),
            ctx.accounts.claimant.key.as_ref(),
            &amount.to_le_bytes(),
        ]);
        require!(verify(proof, dist.root, node.0), AirdropError::InvalidProof);

        set_claimed(&mut dist.bitmap, index);

        token::transfer(
            CpiContext::new(
                ctx.accounts.token_program.to_account_info(),
                Transfer {
                    from: ctx.accounts.vault.to_account_info(),
                    to: ctx.accounts.destination.to_account_info(),
                    authority: ctx.accounts.distributor.to_account_info(),
                },
            ),
            amount,
        )?;

        emit!(Claimed {
            index,
            account: ctx.accounts.claimant.key(),
            amount,
        });
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Init<'info> {
    #[account(mut)]
    pub payer: Signer<'info>,
    #[account(
        init,
        payer = payer,
        space = 8 + 32 + 4 + 1024,
        seeds = [b"dist"],
        bump
    )]
    pub distributor: Account<'info, Distributor>,
    #[account(
        init,
        payer = payer,
        token::mint = mint,
        token::authority = distributor,
    )]
    pub vault: Account<'info, TokenAccount>,
    pub mint: Account<'info, Mint>,
    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
    pub rent: Sysvar<'info, Rent>,
}

#[derive(Accounts)]
pub struct Claim<'info> {
    #[account(mut)]
    pub claimant: Signer<'info>,
    #[account(mut, seeds = [b"dist"], bump)]
    pub distributor: Account<'info, Distributor>,
    #[account(mut)]
    pub vault: Account<'info, TokenAccount>,
    #[account(
        init,
        payer = claimant,
        associated_token::mint = mint,
        associated_token::authority = claimant,
    )]
    pub destination: Account<'info, TokenAccount>,
    pub mint: Account<'info, Mint>,
    pub token_program: Program<'info, Token>,
    pub system_program: Program<'info, System>,
    pub associated_token_program: Program<'info, AssociatedToken>,
    pub rent: Sysvar<'info, Rent>,
}

#[account]
pub struct Distributor {
    pub root: [u8; 32],
    pub bitmap: Vec<u8>,
}

#[event]
pub struct Claimed {
    pub index: u64,
    pub account: Pubkey,
    pub amount: u64,
}

#[error_code]
pub enum AirdropError {
    #[msg("Already claimed")] AlreadyClaimed,
    #[msg("Invalid proof")] InvalidProof,
}

fn get_claimed(bitmap: &Vec<u8>, index: u64) -> bool {
    let byte = (index / 8) as usize;
    if byte >= bitmap.len() {
        return false;
    }
    let mask = 1 << (index % 8);
    bitmap[byte] & mask != 0
}

fn set_claimed(bitmap: &mut Vec<u8>, index: u64) {
    let byte = (index / 8) as usize;
    if bitmap.len() <= byte {
        bitmap.resize(byte + 1, 0);
    }
    let mask = 1 << (index % 8);
    bitmap[byte] |= mask;
}

fn verify(proof: Vec<[u8; 32]>, root: [u8; 32], mut leaf: [u8; 32]) -> bool {
    for p in proof.into_iter() {
        if leaf <= p {
            leaf = keccak::hashv(&[leaf.as_ref(), p.as_ref()]).0;
        } else {
            leaf = keccak::hashv(&[p.as_ref(), leaf.as_ref()]).0;
        }
    }
    leaf == root
}
