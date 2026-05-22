const sampleGarments = [
  {
    id: crypto.randomUUID(),
    name: "Blazer lino marfil",
    type: "capa",
    style: ["minimal", "clasico"],
    weather: ["templado", "frio"],
    agenda: ["trabajo", "evento", "cena"],
    worn: 1,
    image: makeGarmentSvg("#f7efe4", "#30333a", "blazer"),
  },
  {
    id: crypto.randomUUID(),
    name: "Top satinado cereza",
    type: "top",
    style: ["romantico", "clasico"],
    weather: ["templado", "calor"],
    agenda: ["cena", "evento"],
    worn: 0,
    image: makeGarmentSvg("#b84e5d", "#f8dbd3", "top"),
  },
  {
    id: crypto.randomUUID(),
    name: "Jean recto azul",
    type: "bottom",
    style: ["urbano", "minimal"],
    weather: ["templado", "frio"],
    agenda: ["casual", "trabajo"],
    worn: 4,
    image: makeGarmentSvg("#315f86", "#f6f0e9", "pants"),
  },
  {
    id: crypto.randomUUID(),
    name: "Falda midi oliva",
    type: "bottom",
    style: ["romantico", "clasico"],
    weather: ["templado", "calor"],
    agenda: ["trabajo", "cena", "evento"],
    worn: 0,
    image: makeGarmentSvg("#7d9474", "#fffdfa", "skirt"),
  },
  {
    id: crypto.randomUUID(),
    name: "Camisa blanca amplia",
    type: "top",
    style: ["minimal", "clasico"],
    weather: ["templado", "calor", "frio"],
    agenda: ["trabajo", "casual"],
    worn: 2,
    image: makeGarmentSvg("#ffffff", "#c45a68", "shirt"),
  },
  {
    id: crypto.randomUUID(),
    name: "Botines negros",
    type: "shoes",
    style: ["urbano", "clasico"],
    weather: ["templado", "lluvia", "frio"],
    agenda: ["trabajo", "cena", "evento"],
    worn: 3,
    image: makeGarmentSvg("#202126", "#c49a4a", "shoes"),
  },
  {
    id: crypto.randomUUID(),
    name: "Tenis crema",
    type: "shoes",
    style: ["minimal", "urbano"],
    weather: ["templado", "calor"],
    agenda: ["casual", "trabajo"],
    worn: 1,
    image: makeGarmentSvg("#ece5dc", "#7aa7b8", "shoes"),
  },
  {
    id: crypto.randomUUID(),
    name: "Gabardina impermeable",
    type: "capa",
    style: ["clasico", "minimal"],
    weather: ["lluvia", "frio"],
    agenda: ["trabajo", "casual"],
    worn: 0,
    image: makeGarmentSvg("#c49a4a", "#30333a", "coat"),
  },
];

const state = {
  garments: JSON.parse(localStorage.getItem("alta-garments") || "null") || sampleGarments,
  savedLooks: JSON.parse(localStorage.getItem("alta-looks") || "[]"),
  currentLook: [],
};

const lookStage = document.querySelector("#lookStage");
const closetGrid = document.querySelector("#closetGrid");
const calendarList = document.querySelector("#calendarList");
const weatherInput = document.querySelector("#weatherInput");
const agendaInput = document.querySelector("#agendaInput");
const styleInput = document.querySelector("#styleInput");

document.querySelector("#contextForm").addEventListener("change", generateLook);
document.querySelector("#shuffleButton").addEventListener("click", generateLook);
document.querySelector("#saveLookButton").addEventListener("click", saveLook);
document.querySelector("#markWornButton").addEventListener("click", markWorn);
document.querySelector("#garmentUpload").addEventListener("change", uploadGarments);

function generateLook() {
  const context = {
    weather: weatherInput.value,
    agenda: agendaInput.value,
    style: styleInput.value,
  };

  const requiredTypes = context.weather === "calor" ? ["top", "bottom", "shoes"] : ["capa", "top", "bottom", "shoes"];
  state.currentLook = requiredTypes
    .map((type) => bestGarment(type, context))
    .filter(Boolean);

  renderLook(context);
  renderNotes(context);
}

function bestGarment(type, context) {
  const matches = state.garments
    .filter((item) => item.type === type)
    .map((item) => {
      let score = 0;
      if (item.weather.includes(context.weather)) score += 3;
      if (item.agenda.includes(context.agenda)) score += 3;
      if (item.style.includes(context.style)) score += 2;
      if (item.worn === 0) score += 2;
      if (item.worn > 2) score -= 1;
      return { item, score: score + Math.random() };
    })
    .sort((a, b) => b.score - a.score);

  return matches[0]?.item;
}

function renderLook(context) {
  const title = context.agenda === "cena" ? "Pulido con un punto especial" : "Lista para el dia";
  document.querySelector("#lookTitle").textContent = title;
  document.querySelector("#confidenceScore").textContent = `${Math.max(78, 96 - Math.floor(Math.random() * 13))}%`;

  lookStage.innerHTML = "";
  state.currentLook.forEach((item) => {
    const card = document.createElement("article");
    card.className = "look-item";
    card.innerHTML = `
      <div class="look-image" style="--visual: url('${item.image}')"></div>
      <div class="look-copy">
        <strong>${item.name}</strong>
        <span>${labelForType(item.type)} · ${item.worn === 0 ? "rescatar del armario" : `${item.worn} usos recientes`}</span>
      </div>
    `;
    lookStage.append(card);
  });
}

function renderNotes(context) {
  const notes = [
    `Prioriza prendas compatibles con ${context.weather} y agenda de ${context.agenda}.`,
    context.style === "urbano" ? "Equilibra comodidad con una pieza protagonista." : "Mantiene una silueta limpia y facil de repetir.",
    "La IA sube de prioridad lo que casi no has usado.",
  ];

  document.querySelector("#styleNotes").innerHTML = notes.map((note) => `<div class="note">${note}</div>`).join("");
}

function renderCloset() {
  closetGrid.innerHTML = "";
  state.garments.forEach((item) => {
    const template = document.querySelector("#garmentTemplate").content.cloneNode(true);
    const card = template.querySelector(".garment-card");
    card.querySelector(".garment-image").style.setProperty("--visual", `url('${item.image}')`);
    card.querySelector("strong").textContent = item.name;
    card.querySelector("span").textContent = `${labelForType(item.type)} · ${item.worn} usos`;
    card.addEventListener("click", () => {
      item.worn = Math.max(0, item.worn - 1);
      persist();
      renderAll();
    });
    closetGrid.append(template);
  });
}

function renderCalendar() {
  const days = ["Lun", "Mar", "Mie", "Jue", "Vie", "Sab", "Dom"];
  calendarList.innerHTML = days
    .map((day, index) => {
      const saved = state.savedLooks[index];
      const names = saved ? saved.items.map((item) => item.name).join(", ") : "Sin look guardado";
      return `
        <div class="calendar-day">
          <strong>${day}</strong>
          <div>
            <strong>${saved ? saved.name : "Plan pendiente"}</strong>
            <span>${names}</span>
          </div>
        </div>
      `;
    })
    .join("");
}

function renderStats() {
  const total = state.garments.length;
  const rare = state.garments.filter((item) => item.worn === 0).length;
  const used = total ? Math.round(((total - rare) / total) * 100) : 0;

  document.querySelector("#itemCount").textContent = total;
  document.querySelector("#rareCount").textContent = rare;
  document.querySelector("#savedCount").textContent = state.savedLooks.length;
  document.querySelector("#usageScore").textContent = `${used}%`;
  document.querySelector(".meter-fill").style.width = `${used}%`;
}

function saveLook() {
  if (!state.currentLook.length) return;
  state.savedLooks = [
    {
      name: document.querySelector("#lookTitle").textContent,
      items: state.currentLook.map(({ id, name }) => ({ id, name })),
    },
    ...state.savedLooks,
  ].slice(0, 7);
  persist();
  renderAll();
}

function markWorn() {
  const ids = new Set(state.currentLook.map((item) => item.id));
  state.garments = state.garments.map((item) => (ids.has(item.id) ? { ...item, worn: item.worn + 1 } : item));
  persist();
  renderAll();
}

function uploadGarments(event) {
  [...event.target.files].forEach((file) => {
    const reader = new FileReader();
    reader.onload = () => {
      state.garments.unshift({
        id: crypto.randomUUID(),
        name: file.name.replace(/\.[^.]+$/, "").replaceAll("-", " "),
        type: inferType(file.name),
        style: ["minimal", "clasico"],
        weather: ["templado", "calor", "frio"],
        agenda: ["trabajo", "casual"],
        worn: 0,
        image: reader.result,
      });
      persist();
      renderAll();
    };
    reader.readAsDataURL(file);
  });
  event.target.value = "";
}

function inferType(fileName) {
  const lower = fileName.toLowerCase();
  if (lower.includes("zapato") || lower.includes("tenis") || lower.includes("bota")) return "shoes";
  if (lower.includes("falda") || lower.includes("jean") || lower.includes("pantalon")) return "bottom";
  if (lower.includes("chaqueta") || lower.includes("blazer") || lower.includes("abrigo")) return "capa";
  return "top";
}

function labelForType(type) {
  return {
    top: "Superior",
    bottom: "Inferior",
    shoes: "Zapatos",
    capa: "Capa",
  }[type];
}

function persist() {
  localStorage.setItem("alta-garments", JSON.stringify(state.garments));
  localStorage.setItem("alta-looks", JSON.stringify(state.savedLooks));
}

function renderAll() {
  renderCloset();
  renderCalendar();
  renderStats();
  generateLook();
}

function makeGarmentSvg(primary, accent, shape) {
  const bodies = {
    blazer: `<path d="M72 38h56l22 44-24 74H74L50 82l22-44Z" fill="${primary}"/><path d="M94 42l18 38 18-38" fill="none" stroke="${accent}" stroke-width="7"/><path d="M78 62h68" stroke="${accent}" stroke-width="5"/>`,
    top: `<path d="M74 48h52l28 32-19 20-9-10v66H74V90l-9 10-19-20 28-32Z" fill="${primary}"/><path d="M84 58c14 13 42 13 56 0" fill="none" stroke="${accent}" stroke-width="6"/>`,
    pants: `<path d="M77 42h70l-7 116h-35l-7-70-8 70H55L77 42Z" fill="${primary}"/><path d="M78 58h67M102 55l-4 33" stroke="${accent}" stroke-width="5"/>`,
    skirt: `<path d="M75 48h70l25 110H50L75 48Z" fill="${primary}"/><path d="M78 64h64M98 70l-18 78M122 70l16 78" stroke="${accent}" stroke-width="5"/>`,
    shoes: `<path d="M52 106c24 4 43-6 58 12 12 14-17 28-57 18-16-4-23-12-21-21 1-7 8-11 20-9Z" fill="${primary}"/><path d="M116 112c21 1 34-9 50 6 14 13-10 28-45 21-17-3-27-11-26-19 1-6 8-9 21-8Z" fill="${primary}"/><path d="M43 127h67M108 130h66" stroke="${accent}" stroke-width="5"/>`,
    coat: `<path d="M70 34h60l25 36-13 18-10-9 16 82H52l16-82-10 9-13-18 25-36Z" fill="${primary}"/><path d="M100 40v120M78 72h44M82 104h36" stroke="${accent}" stroke-width="6"/>`,
    shirt: `<path d="M70 44h60l28 34-18 20-12-13v72H72V85L60 98 42 78l28-34Z" fill="${primary}"/><path d="M100 48v108M83 68h34" stroke="${accent}" stroke-width="5"/>`,
  };

  const svg = `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
      <rect width="200" height="200" fill="#fbf8f1"/>
      <circle cx="158" cy="42" r="22" fill="${accent}" opacity=".18"/>
      <circle cx="45" cy="165" r="30" fill="${primary}" opacity=".18"/>
      ${bodies[shape] || bodies.shirt}
    </svg>
  `;
  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(svg)}`;
}

renderAll();
