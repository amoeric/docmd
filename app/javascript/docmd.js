// Docmd Engine JavaScript 入口檔
import { Application } from "@hotwired/stimulus"

// 載入所有 Docmd 的 Stimulus controllers
import TreeViewController from "docmd/controllers/docmd/tree_view_controller"

// 如果主應用程式已有 Stimulus 實例，使用它；否則建立新的
const application = window.Stimulus || Application.start()

// 註冊 Docmd 的 controllers
application.register("tree-view", TreeViewController)

// 輸出給主應用程式使用
export { application }