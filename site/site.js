// Daily Hadith site: scroll reveal and nav scrollspy. No dependencies.
(function () {
  "use strict";

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  // --- Scroll reveal: phones and theme pills arrive once, then stay. ---
  var reveals = document.querySelectorAll(".reveal, .themes");
  if ("IntersectionObserver" in window && reveals.length) {
    var revealObserver = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add("is-visible");
            revealObserver.unobserve(entry.target);
          }
        });
      },
      { rootMargin: "0px 0px -80px 0px", threshold: 0.15 }
    );
    reveals.forEach(function (el) {
      revealObserver.observe(el);
    });
  } else {
    reveals.forEach(function (el) {
      el.classList.add("is-visible");
    });
  }

  // --- Nav scrollspy with a sliding pill. ---
  var segmented = document.querySelector(".segmented");
  if (!segmented) return;

  var links = Array.prototype.slice.call(segmented.querySelectorAll("a[href^='#']"));
  if (!links.length) return;

  var pill = document.createElement("span");
  pill.className = "segmented-pill";
  pill.setAttribute("aria-hidden", "true");
  segmented.insertBefore(pill, segmented.firstChild);
  segmented.classList.add("has-pill");

  function movePill(link, instant) {
    if (!link) return;
    if (instant) pill.style.transition = "none";
    pill.style.width = link.offsetWidth + "px";
    pill.style.transform = "translateX(" + link.offsetLeft + "px)";
    if (instant) {
      // Force the style flush so the next move animates again.
      void pill.offsetWidth;
      pill.style.transition = "";
    }
  }

  function setCurrent(link) {
    links.forEach(function (a) {
      if (a === link) {
        a.setAttribute("aria-current", "page");
      } else {
        a.removeAttribute("aria-current");
      }
    });
    movePill(link, reduceMotion.matches);
  }

  var initial = segmented.querySelector("a[aria-current='page']") || links[0];
  movePill(initial, true);

  // Fonts can change link widths after first layout; settle the pill once they load.
  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(function () {
      movePill(segmented.querySelector("a[aria-current='page']") || links[0], true);
    });
  }

  window.addEventListener("resize", function () {
    movePill(segmented.querySelector("a[aria-current='page']") || links[0], true);
  });

  // Map each anchor link to its section; pick the section nearest the top of the viewport.
  var targets = links
    .map(function (a) {
      var id = a.getAttribute("href").slice(1);
      var el = document.getElementById(id);
      return el ? { link: a, el: el } : null;
    })
    .filter(Boolean);

  if (!targets.length) return;

  var ticking = false;
  function updateCurrent() {
    ticking = false;
    var line = window.innerHeight * 0.35;
    var best = targets[0];
    for (var i = 0; i < targets.length; i++) {
      if (targets[i].el.getBoundingClientRect().top <= line) best = targets[i];
    }
    if (best.link.getAttribute("aria-current") !== "page") setCurrent(best.link);
  }

  window.addEventListener(
    "scroll",
    function () {
      if (!ticking) {
        ticking = true;
        window.requestAnimationFrame(updateCurrent);
      }
    },
    { passive: true }
  );

  updateCurrent();
})();
