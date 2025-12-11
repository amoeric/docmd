// Docmd Engine JavaScript 入口檔
// 只導出 controllers，讓主應用程式負責註冊

import TreeViewController from "./controllers/docmd/tree_view_controller"

// 導出所有 controllers
export { TreeViewController }

// 提供方便的註冊函式
export function registerDocmdControllers(application) {
  application.register("docmd--tree-view", TreeViewController)
}