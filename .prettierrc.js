module.exports = {
  singleQuote: true,
  trailingComma: 'es5',
  overrides: [
    {
      files: '*.sol',
      options: {
        printWidth: 80,
        tabWidth: 4,
        useTabs: true,
        singleQuote: false,
        bracketSpacing: false,
      },
    },
  ],
};
