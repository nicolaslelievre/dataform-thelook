module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // Allowed commit types
    "type-enum": [
      2,
      "always",
      ["feat", "fix", "docs", "chore", "refactor", "test", "style", "ci", "perf", "build", "revert"],
    ],
    // Subject must be lowercase
    "subject-case": [2, "always", "lower-case"],
    // Subject max length
    "subject-max-length": [2, "always", 72],
  },
};
