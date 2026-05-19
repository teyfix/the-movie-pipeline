const pluginSql = {
  formatter: "sql-formatter",
  language: "postgresql",
  // dialect: JSON.stringify(require("sql-formatter").postgresql),
  keywordCase: "upper",
  dataTypeCase: "upper",
  functionCase: "lower",
  identifierCase: "preserve",
  indentStyle: "standard",
  logicalOperatorNewline: "before",
  expressionWidth: 50,
  linesBetweenQueries: 1,
  denseOperators: false,
  newlineBeforeSemicolon: false,
  // params: JSON.stringify([]),
  // paramTypes: JSON.stringify([]),
  database: "postgresql",
};

const pluginSortJSON = {
  jsonRecursiveSort: true,
  jsonSortOrder: JSON.stringify({
    id: null,
    type: null,
    name: null,
    title: null,
    "/.*/": "lexical",
  }),
};

/**
 * @type {import('prettier').Options}
 */
const prettierConfig = {
  plugins: ["prettier-plugin-embed", "prettier-plugin-sh", "prettier-plugin-sql", "prettier-plugin-sort-json", "prettier-plugin-packagejson"],
  printWidth: 8000,
  overrides: [
    {
      files: "*.sql.gotpl",
      options: {
        parser: "sql",
      },
    },
    {
      files: "*.yaml.gotpl",
      options: {
        parser: "yaml",
      },
    },
    {
      files: ".vscode/*.json",
      options: {
        printWidth: 80,
      },
    },
  ],
};

/**
 * @type {import('prettier').Options}
 */
const config = {
  ...pluginSql,
  ...pluginSortJSON,
  ...prettierConfig,
};

export default config;
