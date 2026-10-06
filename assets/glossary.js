(() => {
  const terms = [...document.querySelectorAll('.glossary-term')];
  if (!terms.length) return;

  const popup = document.createElement('div');
  popup.className = 'glossary-popup';
  popup.setAttribute('role', 'tooltip');
  // The trigger's description references its persistent glossary definition;
  // this visual copy should not be announced a second time.
  popup.setAttribute('aria-hidden', 'true');
  popup.hidden = true;
  const title = document.createElement('strong');
  const description = document.createElement('p');
  popup.append(title, description);
  document.body.append(popup);

  let active = null;
  let hovered = null;
  let overPopup = false;
  let pinned = false;
  let closeTimer;
  const dismissed = new Set();

  function position() {
    if (!active || popup.hidden) return;
    const rect = active.getBoundingClientRect();
    if (rect.bottom < 0 || rect.top > innerHeight) {
      hide();
      return;
    }
    const width = popup.offsetWidth;
    const height = popup.offsetHeight;
    const left = Math.max(12, Math.min(rect.left, innerWidth - width - 12));
    const below = rect.bottom + 6;
    const top = below + height <= innerHeight - 12 ? below : Math.max(12, rect.top - height - 6);
    popup.style.left = `${left}px`;
    popup.style.top = `${top}px`;
  }

  function show(term) {
    if (dismissed.has(term)) return;
    clearTimeout(closeTimer);
    if (active !== term) pinned = false;
    active = term;
    const definition = document.getElementById(term.getAttribute('aria-describedby'));
    title.textContent = definition.previousElementSibling.textContent;
    description.textContent = definition.textContent;
    popup.hidden = false;
    position();
  }

  function hide() {
    clearTimeout(closeTimer);
    popup.hidden = true;
    active = null;
    pinned = false;
    overPopup = false;
  }

  function scheduleClose() {
    clearTimeout(closeTimer);
    closeTimer = setTimeout(() => {
      if (!pinned && !overPopup && hovered !== active && document.activeElement !== active) hide();
    }, 180);
  }

  terms.forEach(term => {
    term.setAttribute('role', 'button');
    term.addEventListener('pointerenter', event => {
      if (event.pointerType !== 'mouse') return;
      hovered = term;
      show(term);
    });
    term.addEventListener('pointerleave', () => {
      if (hovered === term) hovered = null;
      if (document.activeElement !== term) dismissed.delete(term);
      scheduleClose();
    });
    term.addEventListener('focus', () => show(term));
    term.addEventListener('blur', () => {
      if (hovered !== term) dismissed.delete(term);
      if (active === term) pinned = false;
      scheduleClose();
    });
    term.addEventListener('click', event => {
      // Modified clicks retain the ordinary glossary anchor behavior.
      if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
      event.preventDefault();
      if (active === term && pinned) {
        dismissed.add(term);
        hide();
      } else {
        dismissed.delete(term);
        show(term);
        pinned = true;
      }
    });
    term.addEventListener('keydown', event => {
      if (event.key === ' ') {
        event.preventDefault();
        term.click();
      }
    });
  });

  popup.addEventListener('pointerenter', () => { overPopup = true; clearTimeout(closeTimer); });
  popup.addEventListener('pointerleave', () => { overPopup = false; scheduleClose(); });
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && active) {
      dismissed.add(active);
      hide();
    }
  });
  document.addEventListener('pointerdown', event => {
    if (!event.target.closest('.glossary-term, .glossary-popup')) {
      if (active) dismissed.add(active);
      hide();
    }
  });

  function openTarget() {
    let id;
    try { id = decodeURIComponent(location.hash.slice(1)); } catch { return; }
    if (!id.startsWith('glossary-')) return;
    const target = document.getElementById(id);
    const glossary = target?.closest('.article-glossary');
    if (glossary) {
      glossary.open = true;
      target.scrollIntoView({ block: 'start' });
    }
  }
  window.addEventListener('hashchange', openTarget);
  window.addEventListener('resize', position);
  window.addEventListener('scroll', position, { passive: true });
  window.addEventListener('beforeprint', () => {
    document.querySelectorAll('.article-glossary').forEach(glossary => {
      glossary.dataset.openBeforePrint = String(glossary.open);
      glossary.open = true;
    });
    hide();
  });
  window.addEventListener('afterprint', () => {
    document.querySelectorAll('.article-glossary').forEach(glossary => {
      glossary.open = glossary.dataset.openBeforePrint === 'true';
      delete glossary.dataset.openBeforePrint;
    });
  });
  openTarget();
})();
