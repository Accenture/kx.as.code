const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin");
const path = require("path");
const CopyPlugin = require("copy-webpack-plugin");

module.exports = [
  new ForkTsCheckerWebpackPlugin(),
  new CopyPlugin({
    patterns: [
      {
        from: path.resolve(__dirname, "src", "media"),
        to: path.resolve(__dirname, ".webpack/renderer", "media"),
      },
    ],
    options: {
      concurrency: 100,
    },
  }),
];
