import { describe, it, expect } from 'vitest'
import { readFileSync, statSync } from 'fs'

describe('repo sanity', () => {
  it('CODex_MASTER_PROMPT.md exists & is non-empty', () => {
    const s = statSync('CODex_MASTER_PROMPT.md')
    expect(s.size).toBeGreaterThan(128)
  })

  it('Makefile exists & exposes a ci target', () => {
    const content = readFileSync('Makefile', 'utf8')
    expect(content).toMatch(/\bci\b/)
  })
})
