import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["icon", "content", "indicator"];
  static values = {
    animate: { type: Boolean, default: true }, // Whether to animate the tree view
  };

  connect() {
    this.isAnimating = false;
    this.isScrolling = false; // 追蹤是否正在滾動
    // Initialize any folders that should start open
    this.element.querySelectorAll('[data-state="open"]').forEach((el) => {
      const button = el.previousElementSibling;
      if (button) {
        const icon = button.querySelector('[data-tree-view-target="icon"]');
        if (icon) {
          icon.classList.add("folder-open");
          icon.innerHTML = this.openFolderSvg;
        }
      }
    });

    this.addKeyboardListeners();

    // 延遲設置 scroll spy，確保 DOM 完全載入
    setTimeout(() => {
      this.setupScrollSpy();
    }, 100);
  }

  disconnect() {
    // Clean up any remaining event listeners
    if (this.onTransitionEndBound) {
      this.element.querySelectorAll('[data-tree-view-target="content"]').forEach((content) => {
        content.removeEventListener("transitionend", this.onTransitionEndBound);
      });
    }
    this.element.removeEventListener("keydown", this.handleKeydownBound);

    // Clean up scroll spy
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect();
    }
  }

  addKeyboardListeners() {
    this.handleKeydownBound = this.handleKeydown.bind(this);
    this.element.addEventListener("keydown", this.handleKeydownBound);
  }

  handleKeydown(event) {
    const triggers = Array.from(this.element.querySelectorAll('button[data-action="click->tree-view#toggle"]'));
    const currentIndex = triggers.indexOf(document.activeElement);
    if (currentIndex === -1) return;

    switch (event.key) {
      case "ArrowUp":
        event.preventDefault();
        let prevIndex = currentIndex;
        do {
          prevIndex = (prevIndex - 1 + triggers.length) % triggers.length;
        } while (prevIndex !== currentIndex && this.isElementHidden(triggers[prevIndex]));
        triggers[prevIndex].focus();
        break;
      case "ArrowDown":
        event.preventDefault();
        let nextIndex = currentIndex;
        do {
          nextIndex = (nextIndex + 1) % triggers.length;
        } while (nextIndex !== currentIndex && this.isElementHidden(triggers[nextIndex]));
        triggers[nextIndex].focus();
        break;
      case "Enter":
      case " ":
        event.preventDefault();
        triggers[currentIndex].click();
        break;
    }
  }

  isElementHidden(element) {
    let current = element;
    while (current && current !== this.element) {
      if (current.hasAttribute("hidden") || current.classList.contains("hidden")) {
        return true;
      }
      current = current.parentElement;
    }
    return false;
  }

  toggle(event) {
    const button = event.currentTarget;
    const content = document.getElementById(button.getAttribute("aria-controls"));
    const icon = button.querySelector('[data-tree-view-target="icon"]');

    // Prevent multiple animations from running simultaneously
    if (this.isAnimating) return;

    const isOpen = button.getAttribute("aria-expanded") === "true";

    // Toggle aria attributes
    button.setAttribute("aria-expanded", !isOpen);
    content.setAttribute("data-state", isOpen ? "closed" : "open");

    if (this.animateValue) {
      this.isAnimating = true;

      // Remove any existing transition listeners
      content.removeEventListener("transitionend", this.onTransitionEndBound);
      this.onTransitionEndBound = () => {
        if (isOpen) {
          content.setAttribute("hidden", "");
        }
        content.style.height = "";
        content.style.transition = "";
        content.removeEventListener("transitionend", this.onTransitionEndBound);
        this.isAnimating = false;
      };
      content.addEventListener("transitionend", this.onTransitionEndBound);

      if (isOpen) {
        // Closing animation
        const height = content.scrollHeight;
        content.style.height = height + "px";
        // Force a reflow
        content.offsetHeight;
        content.style.transition = "height 300ms ease-out";
        content.style.height = "0";
      } else {
        // Opening animation
        content.removeAttribute("hidden");
        content.style.height = "0";
        // Force a reflow
        content.offsetHeight;
        content.style.transition = "height 300ms ease-out";
        const height = content.scrollHeight;
        content.style.height = height + "px";
      }
    } else {
      // No animation - just toggle visibility
      if (isOpen) {
        content.setAttribute("hidden", "");
      } else {
        content.removeAttribute("hidden");
      }
    }

    // Update icons
    if (isOpen) {
      icon.classList.remove("folder-open");
      icon.innerHTML = this.closedFolderSvg;
    } else {
      icon.classList.add("folder-open");
      icon.innerHTML = this.openFolderSvg;
    }

    // Update button state
    button.setAttribute("data-state", isOpen ? "closed" : "open");
  }

  get openFolderSvg() {
    return `<g fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" stroke="currentColor">
      <path d="M5,14.75h-.75c-1.105,0-2-.895-2-2V4.75c0-1.105,.895-2,2-2h1.825c.587,0,1.144,.258,1.524,.705l1.524,1.795h4.626c1.105,0,2,.895,2,2v1"></path>
      <path d="M16.148,13.27l.843-3.13c.257-.953-.461-1.89-1.448-1.89H6.15c-.678,0-1.272,.455-1.448,1.11l-.942,3.5c-.257,.953,.461,1.89,1.448,1.89H14.217c.904,0,1.696-.607,1.931-1.48Z"></path>
    </g>`;
  }

  get closedFolderSvg() {
    return `<g fill="none" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" stroke="currentColor">
      <path d="M13.75,5.25c1.105,0,2,.895,2,2v5.5c0,1.105-.895,2-2,2H4.25c-1.105,0-2-.895-2-2V4.75c0-1.105,.895-2,2-2h1.825c.587,0,1.144,.258,1.524,.705l1.524,1.795h4.626Z"></path>
    </g>`;
  }

  scrollToHeading(event) {
    event.preventDefault();
    const link = event.currentTarget;
    const targetId = link.getAttribute("href").substring(1);
    const targetElement = document.getElementById(targetId);

    if (targetElement) {
      // 標記開始滾動，暫時禁用 scroll spy
      this.isScrolling = true;

      // 立即高亮點擊的項目
      this.highlightTocItem(targetId);

      // 平滑滾動到目標標題
      targetElement.scrollIntoView({
        behavior: "smooth",
        block: "start"
      });

      // 可選：高亮顯示目標標題
      targetElement.classList.add("highlight-heading");
      setTimeout(() => {
        targetElement.classList.remove("highlight-heading");
      }, 2000);

      // 滾動完成後重新啟用 scroll spy
      setTimeout(() => {
        this.isScrolling = false;
      }, 1000);
    }
  }

  setupScrollSpy() {
    // 找到所有文件中的標題
    const headings = document.querySelectorAll('.markdown-content h1, .markdown-content h2, .markdown-content h3');

    if (!headings.length) return;

    // 找到滾動容器（包含 markdown-content 的父容器）
    const scrollContainer = document.querySelector('.markdown-content')?.closest('.overflow-y-auto');

    // 設定 Intersection Observer
    const observerOptions = {
      root: scrollContainer, // 監聽自定義滾動容器，而不是整個視窗
      rootMargin: '-80px 0px -80% 0px', // 當標題在容器上方 80px 位置時觸發
      threshold: 0
    };

    this.intersectionObserver = new IntersectionObserver((entries) => {
      // 如果正在滾動（用戶點擊了 TOC），暫時不更新高亮
      if (this.isScrolling) return;

      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const id = entry.target.id;
          this.highlightTocItem(id);
        }
      });
    }, observerOptions);

    // 觀察所有標題
    headings.forEach(heading => {
      if (heading.id) {
        this.intersectionObserver.observe(heading);
      }
    });
  }

  highlightTocItem(headingId) {
    // 移除所有現有的高亮並隱藏所有指示器
    const allItems = this.element.querySelectorAll('a[href^="#"], button[data-heading-id]');
    allItems.forEach(item => {
      item.classList.remove('bg-red-100', 'dark:bg-red-900/30', 'text-red-600', 'dark:text-red-400');
      const indicator = item.querySelector('[data-docmd--tree-view-target="indicator"]');
      if (indicator) {
        indicator.classList.add('hidden');
      }
    });

    // 高亮當前項目
    const tocLink = this.element.querySelector(`a[href="#${headingId}"]`);
    if (tocLink) {
      tocLink.classList.add('bg-red-100', 'dark:bg-red-900/30', 'text-red-600', 'dark:text-red-400');
      const indicator = tocLink.querySelector('[data-docmd--tree-view-target="indicator"]');
      if (indicator) {
        indicator.classList.remove('hidden');
      }

      // 只滾動 TOC 容器內部，不影響頁面滾動
      this.scrollToItemInToc(tocLink);
    }

    // 檢查是否需要展開父資料夾
    const button = this.element.querySelector(`button[data-heading-id="${headingId}"]`);
    if (button) {
      button.classList.add('bg-red-100', 'dark:bg-red-900/30', 'text-red-600', 'dark:text-red-400');
      const indicator = button.querySelector('[data-docmd--tree-view-target="indicator"]');
      if (indicator) {
        indicator.classList.remove('hidden');
      }

      // 只滾動 TOC 容器內部，不影響頁面滾動
      this.scrollToItemInToc(button);
    }
  }

  scrollToItemInToc(item) {
    const container = this.element;
    const containerRect = container.getBoundingClientRect();
    const itemRect = item.getBoundingClientRect();

    // 檢查項目是否在可見區域內
    const isVisible =
      itemRect.top >= containerRect.top &&
      itemRect.bottom <= containerRect.bottom;

    // 如果不可見，滾動容器讓它可見
    if (!isVisible) {
      const scrollTop = container.scrollTop;
      const itemOffsetTop = item.offsetTop;
      const containerHeight = container.clientHeight;
      const itemHeight = item.clientHeight;

      // 計算需要滾動的位置（讓項目在容器中央）
      const targetScroll = itemOffsetTop - (containerHeight / 2) + (itemHeight / 2);

      container.scrollTo({
        top: targetScroll,
        behavior: "smooth"
      });
    }
  }
}
