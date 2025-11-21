import { Controller } from "@hotwired/stimulus"

// 用於編輯頁面的預覽控制器
export default class extends Controller {
  connect() {
    console.log("Docmd Preview controller connected")
  }

  // 當點擊預覽按鈕時觸發
  submitPreview(event) {
    event.preventDefault()

    // 取得表單元素
    const form = this.element.closest('form') || this.element

    // 建立 FormData
    const formData = new FormData(form)

    // 使用 fetch 來提交表單到 preview action
    fetch('/docmd/docs/preview', {
      method: 'POST',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'Accept': 'text/vnd.turbo-stream.html, text/html'
      }
    })
    .then(response => response.text())
    .then(html => {
      // Turbo 會自動處理回應並更新對應的 turbo-frame
      // 如果需要手動處理，可以在這裡加入邏輯
    })
    .catch(error => {
      console.error('預覽錯誤:', error)
    })
  }
}