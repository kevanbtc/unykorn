import { describe, it, expect } from 'vitest'
import fs from 'fs'

it('README contains “RWA evaluation workbook” section', () => {
  const md = fs.readFileSync('README.md','utf8')
  expect(md).toMatch(/RWA (evaluation|playbook) workbook/i)
})

it('Makefile exposes ci & release targets', () => {
  const mk = fs.readFileSync('Makefile','utf8')
  expect(mk).toMatch(/\bci:/)
  expect(mk).toMatch(/\brelease:/)
})

it('CODex master prompt has SYSTEM GUARDRAILS and TESTING MATRIX', () => {
  const md = fs.readFileSync('CODex_MASTER_PROMPT.md','utf8')
  expect(md).toMatch(/SYSTEM GUARDRAILS/i)
  expect(md).toMatch(/TESTING MATRIX/i)
})
