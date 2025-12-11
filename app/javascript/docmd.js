// Docmd Engine JavaScript 入口檔
// 自動註冊 docmd 的 Stimulus controllers

import { Application } from "@hotwired/stimulus"
import TreeViewController from "docmd/controllers/docmd/tree_view_controller"

// 使用主應用程式的 Stimulus 實例，或建立新的
const application = window.Stimulus || Application.start()

// 註冊 Docmd 的 controllers
application.register("docmd--tree-view", TreeViewController)

// 導出供主應用程式使用
export { TreeViewController, application }