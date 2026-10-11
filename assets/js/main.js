/**
 * BRONZE ERA // Global Site Scripts
 * Handles coupon copy, tabs filtering, and toast feedback.
 */

function copyCode(code, btn) {
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(code).then(() => {
      showToast(`专属优惠码 [${code}] 已复制到剪贴板`);
      tempBtnActive(btn);
    }).catch(() => {
      fallbackCopy(code, btn);
    });
  } else {
    fallbackCopy(code, btn);
  }
}

function fallbackCopy(code, btn) {
  const ta = document.createElement('textarea');
  ta.value = code;
  ta.style.position = 'fixed';
  ta.style.opacity = '0';
  document.body.appendChild(ta);
  ta.select();
  try {
    document.execCommand('copy');
    showToast(`优惠代码 [${code}] 复制成功`);
    tempBtnActive(btn);
  } catch (err) {
    showToast(`请手动复制：${code}`);
  }
  document.body.removeChild(ta);
}

function tempBtnActive(btn) {
  if (!btn) return;
  const original = btn.innerText;
  btn.innerText = "✓ 已复制";
  setTimeout(() => {
    btn.innerText = original;
  }, 1800);
}

function showToast(msg) {
  let toast = document.getElementById('toastNotice');
  if (!toast) {
    toast = document.createElement('div');
    toast.id = 'toastNotice';
    toast.className = 'toast-msg';
    document.body.appendChild(toast);
  }
  toast.innerText = msg;
  toast.classList.add('show');
  setTimeout(() => {
    toast.classList.remove('show');
  }, 2400);
}

// Airport Card Category Filter
function filterAirports(category, btn) {
  const pills = document.querySelectorAll('.pill-btn');
  pills.forEach(p => p.classList.remove('active'));
  if (btn) btn.classList.add('active');

  const cards = document.querySelectorAll('.airport-card');
  cards.forEach(card => {
    if (category === 'all') {
      card.style.display = '';
    } else {
      const cardCats = card.getAttribute('data-cats') || '';
      if (cardCats.includes(category)) {
        card.style.display = '';
      } else {
        card.style.display = 'none';
      }
    }
  });
}
