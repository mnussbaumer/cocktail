// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";
import "./editor";

import {transform_panel, on_update} from "./editor_transforms";


// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import LiveSocket from "./live_test.js";//"phoenix_live_view";

let liveSocket = new LiveSocket("/cocktail-editor/live", {inject: {"Cocktail.View.Panel": transform_panel, "Cocktail.View.Element": transform_panel, "Cocktail.View.Editor": transform_panel}}) //, on_update: on_update}});
liveSocket.connect();
console.log(liveSocket);
