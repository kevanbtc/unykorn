module.exports = {
  root: true,
  env: {
    node: true,
    es2021: true,
    mocha: true,
  },
  parser: "@typescript-eslint/parser",
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier",
  ],
  plugins: ["@typescript-eslint", "prettier"],
  ignorePatterns: ["dist/", "node_modules/"],
  rules: {
    "prettier/prettier": "error",
    "@typescript-eslint/no-var-requires": "off",
    "@typescript-eslint/no-require-imports": "off",
    "@typescript-eslint/no-unused-expressions": "off",
  },
};
