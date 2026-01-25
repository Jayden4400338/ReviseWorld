/* Demo-only logic: no Supabase, no auth, just sample content + interactions */

(function () {
  // ---------- Helpers ----------
  const $ = (id) => document.getElementById(id);

  function escapeHtml(str) {
    return String(str)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");
  }

  // ---------- Flashcards ----------
  const flashcards = [
    {
      front: "What is the function of the nucleus in a cell?",
      back: "It contains genetic material (DNA) and controls the cell’s activities."
    },
    {
      front: "Define osmosis.",
      back: "The movement of water from a dilute solution to a more concentrated solution through a partially permeable membrane."
    },
    {
      front: "What is a catalyst?",
      back: "A substance that increases the rate of a reaction without being used up (lowers activation energy)."
    },
    {
      front: "What does 'respiration' release energy from?",
      back: "From glucose (usually with oxygen in aerobic respiration)."
    },
    {
      front: "Name one adaptation of red blood cells.",
      back: "Biconcave shape for larger surface area; no nucleus to carry more oxygen; flexible to fit through capillaries."
    }
  ];

  let fcIndex = 0;
  let fcFlipped = false;

  const flashcard = $("flashcard");
  const fcFrontText = $("fcFrontText");
  const fcBackText = $("fcBackText");
  const fcProgress = $("fcProgress");
  const fcPrevBtn = $("fcPrevBtn");
  const fcNextBtn = $("fcNextBtn");
  const fcFlipBtn = $("fcFlipBtn");
  const fcResetBtn = $("fcResetBtn");

  function renderFlashcard() {
    const card = flashcards[fcIndex];
    fcFrontText.textContent = card.front;
    fcBackText.textContent = card.back;
    fcProgress.textContent = `${fcIndex + 1} / ${flashcards.length}`;

    // reset flip when moving
    fcFlipped = false;
    flashcard.classList.remove("is-flipped");

    fcPrevBtn.disabled = fcIndex === 0;
    fcNextBtn.disabled = fcIndex === flashcards.length - 1;
  }

  function flipFlashcard() {
    fcFlipped = !fcFlipped;
    flashcard.classList.toggle("is-flipped", fcFlipped);
  }

  if (flashcard) {
    flashcard.addEventListener("click", flipFlashcard);
    flashcard.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        flipFlashcard();
      }
    });
  }

  if (fcFlipBtn) fcFlipBtn.addEventListener("click", flipFlashcard);
  if (fcPrevBtn) fcPrevBtn.addEventListener("click", () => { fcIndex = Math.max(0, fcIndex - 1); renderFlashcard(); });
  if (fcNextBtn) fcNextBtn.addEventListener("click", () => { fcIndex = Math.min(flashcards.length - 1, fcIndex + 1); renderFlashcard(); });
  if (fcResetBtn) fcResetBtn.addEventListener("click", () => { fcIndex = 0; renderFlashcard(); });

  // ---------- Quiz ----------
  const quiz = [
    {
      q: "Simplify: 3x + 5x",
      options: ["8", "8x", "15x", "x^8"],
      answerIndex: 1,
      explain: "Like terms add: 3x + 5x = 8x."
    },
    {
      q: "Solve: 2x + 3 = 11",
      options: ["x = 4", "x = 7", "x = 11", "x = 14"],
      answerIndex: 0,
      explain: "2x = 8 → x = 4."
    },
    {
      q: "Expand: (x + 2)(x + 3)",
      options: ["x^2 + 5x + 6", "x^2 + 6x + 5", "x^2 + 2x + 3", "2x^2 + 5x + 6"],
      answerIndex: 0,
      explain: "FOIL: x·x + x·3 + 2·x + 2·3 = x^2 + 5x + 6."
    }
  ];

  let quizIndex = 0;
  let quizScore = 0;
  let quizLocked = false;

  const quizProgress = $("quizProgress");
  const quizQuestion = $("quizQuestion");
  const quizOptions = $("quizOptions");
  const quizFeedback = $("quizFeedback");
  const quizNextBtn = $("quizNextBtn");
  const quizRestartBtn = $("quizRestartBtn");

  function renderQuiz() {
    const item = quiz[quizIndex];
    quizProgress.textContent = `Q${quizIndex + 1} / ${quiz.length}`;
    quizQuestion.textContent = item.q;
    quizFeedback.textContent = "";
    quizOptions.innerHTML = "";
    quizNextBtn.disabled = true;
    quizLocked = false;

    item.options.forEach((opt, idx) => {
      const btn = document.createElement("button");
      btn.className = "quiz-option";
      btn.type = "button";
      btn.innerHTML = escapeHtml(opt);
      btn.addEventListener("click", () => handleQuizPick(idx, btn));
      quizOptions.appendChild(btn);
    });
  }

  function lockQuizOptions() {
    quizLocked = true;
    [...quizOptions.querySelectorAll("button")].forEach((b) => (b.disabled = true));
  }

  function handleQuizPick(choiceIndex, btnEl) {
    if (quizLocked) return;

    const item = quiz[quizIndex];
    const correct = choiceIndex === item.answerIndex;

    lockQuizOptions();

    // Mark correct + incorrect quickly without relying on colors
    const allBtns = [...quizOptions.querySelectorAll("button")];
    allBtns[item.answerIndex].innerHTML = `✅ ${allBtns[item.answerIndex].innerHTML}`;
    if (!correct) btnEl.innerHTML = `❌ ${btnEl.innerHTML}`;

    if (correct) {
      quizScore++;
      quizFeedback.textContent = `Correct. ${item.explain}`;
    } else {
      quizFeedback.textContent = `Not quite. ${item.explain}`;
    }

    quizNextBtn.disabled = false;

    // If last question, change button label
    if (quizIndex === quiz.length - 1) {
      quizNextBtn.innerHTML = `Finish <i class="fa-solid fa-flag-checkered"></i>`;
    } else {
      quizNextBtn.innerHTML = `Next <i class="fa-solid fa-chevron-right"></i>`;
    }
  }

  function finishQuiz() {
    quizQuestion.textContent = "Quiz complete 🎉";
    quizOptions.innerHTML = "";
    quizFeedback.textContent = `Score: ${quizScore} / ${quiz.length}. Want to try again?`;
    quizProgress.textContent = `Done`;
    quizNextBtn.disabled = true;
  }

  if (quizNextBtn) {
    quizNextBtn.addEventListener("click", () => {
      if (quizIndex < quiz.length - 1) {
        quizIndex++;
        renderQuiz();
      } else {
        finishQuiz();
      }
    });
  }

  if (quizRestartBtn) {
    quizRestartBtn.addEventListener("click", () => {
      quizIndex = 0;
      quizScore = 0;
      renderQuiz();
    });
  }

  // ---------- Past paper (sample-only) ----------
  const pp = {
    question:
      "A student argues that social media always harms teenagers. Write a short response that presents a balanced view.",
    markscheme: [
      "Clear viewpoint with balance (both positives and negatives).",
      "Relevant examples (e.g., connection, learning, wellbeing, distraction).",
      "Organised, coherent paragraphs and accurate tone.",
      "Some persuasive methods (contrast, rhetorical question, emphasis) where appropriate."
    ],
    tips: [
      "Start with a concession: 'While it can…, it can also…'.",
      "Use one concrete example (a study group, news awareness, support networks).",
      "Avoid absolute words like 'always' / 'never' — qualify your points.",
      "End with a judgement: conditions where it helps vs harms."
    ]
  };

  const ppQuestion = $("ppQuestion");
  const ppMarkscheme = $("ppMarkscheme");
  const ppTips = $("ppTips");
  const ppRevealBtn = $("ppRevealBtn");
  const ppClearBtn = $("ppClearBtn");
  const ppReveal = $("ppReveal");
  const ppAnswer = $("ppAnswer");

  function renderPastPaper() {
    if (ppQuestion) ppQuestion.textContent = pp.question;

    if (ppMarkscheme) {
      ppMarkscheme.innerHTML = "";
      pp.markscheme.forEach((x) => {
        const li = document.createElement("li");
        li.textContent = x;
        ppMarkscheme.appendChild(li);
      });
    }

    if (ppTips) {
      ppTips.innerHTML = "";
      pp.tips.forEach((x) => {
        const li = document.createElement("li");
        li.textContent = x;
        ppTips.appendChild(li);
      });
    }
  }

  if (ppRevealBtn) {
    ppRevealBtn.addEventListener("click", () => {
      const nowHidden = !ppReveal.hidden;
      ppReveal.hidden = nowHidden;
      ppRevealBtn.textContent = nowHidden ? "Reveal mark scheme" : "Hide mark scheme";
    });
  }

  if (ppClearBtn) {
    ppClearBtn.addEventListener("click", () => {
      if (ppAnswer) ppAnswer.value = "";
    });
  }

  // ---------- Mini board ----------
  const boardSubject = $("boardSubject");
  const boardTopic = $("boardTopic");
  const boardNote = $("boardNote");
  const boardAddBtn = $("boardAddBtn");
  const boardClearBtn = $("boardClearBtn");
  const boardList = $("boardList");
  const boardEmpty = $("boardEmpty");
  const boardCount = $("boardCount");

  let boardItems = [];

  function updateBoardUI() {
    if (!boardList || !boardEmpty || !boardCount) return;

    boardList.innerHTML = "";

    boardItems.forEach((item) => {
      const wrap = document.createElement("div");
      wrap.className = "board-item";

      const top = document.createElement("div");
      top.className = "board-item-top";

      const badges = document.createElement("div");
      badges.className = "board-badges";

      const b1 = document.createElement("span");
      b1.className = "board-badge";
      b1.textContent = item.subject;

      const b2 = document.createElement("span");
      b2.className = "board-badge";
      b2.textContent = item.topic || "General";

      badges.appendChild(b1);
      badges.appendChild(b2);

      const del = document.createElement("button");
      del.className = "board-delete";
      del.type = "button";
      del.innerHTML = `<i class="fa-solid fa-trash"></i>`;
      del.addEventListener("click", () => {
        boardItems = boardItems.filter((x) => x.id !== item.id);
        updateBoardUI();
      });

      top.appendChild(badges);
      top.appendChild(del);

      const note = document.createElement("div");
      note.className = "board-item-note";
      note.textContent = item.note;

      wrap.appendChild(top);
      wrap.appendChild(note);

      boardList.appendChild(wrap);
    });

    boardEmpty.style.display = boardItems.length ? "none" : "block";
    boardCount.textContent = `${boardItems.length} card${boardItems.length === 1 ? "" : "s"}`;
  }

  if (boardAddBtn) {
    boardAddBtn.addEventListener("click", () => {
      const subject = boardSubject?.value || "Subject";
      const topic = (boardTopic?.value || "").trim();
      const note = (boardNote?.value || "").trim();

      if (!note) {
        // Gentle inline feedback: reuse the note box placeholder behavior
        boardNote?.focus();
        return;
      }

      boardItems.unshift({
        id: crypto?.randomUUID ? crypto.randomUUID() : String(Date.now() + Math.random()),
        subject,
        topic,
        note
      });

      if (boardTopic) boardTopic.value = "";
      if (boardNote) boardNote.value = "";

      updateBoardUI();
    });
  }

  if (boardClearBtn) {
    boardClearBtn.addEventListener("click", () => {
      boardItems = [];
      updateBoardUI();
    });
  }

  // ---------- Init ----------
  renderFlashcard();
  renderQuiz();
  renderPastPaper();
  updateBoardUI();
})();
