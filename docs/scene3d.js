import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { RoomEnvironment } from 'three/addons/environments/RoomEnvironment.js';

const KEYFRAMES = [
  { p: 0.0, rotY: -0.18, rotX: 0.04, rotZ: 0.02, y: 0.0, camZ: 4.1 },
  { p: 0.25, rotY: 0.52, rotX: -0.06, rotZ: -0.02, y: 0.06, camZ: 3.75 },
  { p: 0.55, rotY: -0.42, rotX: 0.1, rotZ: 0.03, y: 0.0, camZ: 3.55 },
  { p: 0.82, rotY: 0.34, rotX: -0.05, rotZ: -0.02, y: 0.04, camZ: 3.85 },
  { p: 1.0, rotY: 0.06, rotX: 0.02, rotZ: 0.0, y: 0.0, camZ: 4.05 },
];

const CHAPTER_LABELS = {
  intro: '01 / PENGENALAN',
  fitur: '02 / FITUR UTAMA',
  filosofi: '03 / FILOSOFI',
  rilis: '04 / RILIS',
  kredit: '05 / KREDIT & LISENSI',
};

function clamp(v, lo, hi) {
  return Math.max(lo, Math.min(hi, v));
}

function lerp(a, b, t) {
  return a + (b - a) * t;
}

function smoothstep(t) {
  return t * t * (3 - 2 * t);
}

function samplePose(p) {
  if (p <= KEYFRAMES[0].p) return KEYFRAMES[0];
  for (let i = 0; i < KEYFRAMES.length - 1; i++) {
    const a = KEYFRAMES[i];
    const b = KEYFRAMES[i + 1];
    if (p <= b.p) {
      const t = smoothstep(clamp((p - a.p) / Math.max(1e-4, b.p - a.p), 0, 1));
      return {
        rotY: lerp(a.rotY, b.rotY, t),
        rotX: lerp(a.rotX, b.rotX, t),
        rotZ: lerp(a.rotZ, b.rotZ, t),
        y: lerp(a.y, b.y, t),
        camZ: lerp(a.camZ, b.camZ, t),
      };
    }
  }
  return KEYFRAMES[KEYFRAMES.length - 1];
}

function initShowcase() {
  const stageEl = document.getElementById('stage-3d');
  const canvas = document.getElementById('canvas-3d');
  if (!stageEl || !canvas) return;

  let renderer;
  try {
    renderer = new THREE.WebGLRenderer({
      canvas,
      antialias: true,
      alpha: true,
      powerPreference: 'high-performance',
    });
  } catch {
    return;
  }

  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
  renderer.toneMapping = THREE.ACESFilmicToneMapping;
  renderer.toneMappingExposure = 0.94;

  const scene = new THREE.Scene();
  const pmrem = new THREE.PMREMGenerator(renderer);
  scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
  scene.environmentIntensity = 0.48;

  const camera = new THREE.PerspectiveCamera(34, 1, 0.1, 40);
  camera.position.set(0, 0.02, 4.1);

  const warmKey = new THREE.DirectionalLight(0xfff4e6, 1.25);
  warmKey.position.set(3.2, 4.0, 5.0);
  scene.add(warmKey);

  const softFill = new THREE.DirectionalLight(0xeef6ff, 0.45);
  softFill.position.set(-3.8, 1.4, 2.8);
  scene.add(softFill);

  const roseRim = new THREE.DirectionalLight(0xf472b6, 0.85);
  roseRim.position.set(-2.4, 2.2, -3.4);
  scene.add(roseRim);

  const pivot = new THREE.Group();
  scene.add(pivot);

  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  let dragYaw = 0;
  let dragPitch = 0;
  let hoverX = 0;
  let hoverY = 0;
  let isDragging = false;
  let prevX = 0;
  let prevY = 0;

  stageEl.addEventListener('pointerdown', (e) => {
    isDragging = true;
    prevX = e.clientX;
    prevY = e.clientY;
    stageEl.setPointerCapture(e.pointerId);
  });

  stageEl.addEventListener('pointermove', (e) => {
    const rect = stageEl.getBoundingClientRect();
    if (rect.width > 0 && rect.height > 0) {
      hoverX = ((e.clientX - rect.left) / rect.width - 0.5) * 2;
      hoverY = ((e.clientY - rect.top) / rect.height - 0.5) * 2;
    }
    if (!isDragging) return;
    const dx = e.clientX - prevX;
    const dy = e.clientY - prevY;
    prevX = e.clientX;
    prevY = e.clientY;
    dragYaw += dx * 0.011;
    dragPitch = clamp(dragPitch + dy * 0.008, -0.55, 0.55);
  });

  const endDrag = () => {
    isDragging = false;
  };
  stageEl.addEventListener('pointerup', endDrag);
  stageEl.addEventListener('pointercancel', endDrag);
  stageEl.addEventListener('pointerleave', () => {
    hoverX = 0;
    hoverY = 0;
  });

  function resize() {
    const w = Math.max(1, stageEl.clientWidth);
    const h = Math.max(1, stageEl.clientHeight);
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  }
  resize();
  if ('ResizeObserver' in window) {
    new ResizeObserver(resize).observe(stageEl);
  }
  window.addEventListener('resize', resize, { passive: true });

  const chapterEl = document.getElementById('stage-chapter');
  const progressBar = document.getElementById('scroll-progress-bar');
  const chapterEls = Array.from(document.querySelectorAll('[data-chapter]'));

  function computeScrollProgress() {
    const doc = document.documentElement;
    const maxScroll = Math.max(1, doc.scrollHeight - window.innerHeight);
    return clamp(window.scrollY / maxScroll, 0, 1);
  }

  function updateChapterHud(p) {
    if (progressBar) {
      progressBar.style.transform = `scaleX(${p.toFixed(4)})`;
    }
    if (!chapterEl || chapterEls.length === 0) return;
    const triggerY = window.innerHeight * 0.36;
    let activeKey = chapterEls[0].dataset.chapter;
    for (const el of chapterEls) {
      if (el.getBoundingClientRect().top <= triggerY) {
        activeKey = el.dataset.chapter;
      }
    }
    const label = CHAPTER_LABELS[activeKey];
    if (label && chapterEl.textContent !== label) {
      chapterEl.textContent = label;
    }
  }

  let curRotY = KEYFRAMES[0].rotY;
  let curRotX = KEYFRAMES[0].rotX;
  let curRotZ = KEYFRAMES[0].rotZ;
  let curY = KEYFRAMES[0].y;
  let curCamZ = KEYFRAMES[0].camZ;
  let curHoverX = 0;
  let curHoverY = 0;
  let elapsed = 0;
  let lastTime = performance.now();
  let rafId = 0;
  let loaded = false;

  const loader = new GLTFLoader();
  loader.load(
    './models/langkah-kecil.glb',
    (gltf) => {
      const model = gltf.scene;
      const upright = new THREE.Group();
      upright.rotation.x = Math.PI / 2;
      const box = new THREE.Box3().setFromObject(model);
      const center = box.getCenter(new THREE.Vector3());
      const size = box.getSize(new THREE.Vector3());
      const maxDim = Math.max(size.x, size.y, size.z) || 1;
      const normScale = 1.72 / maxDim;

      model.position.sub(center);
      upright.add(model);
      upright.scale.setScalar(normScale);
      pivot.add(upright);

      loaded = true;
      stageEl.classList.add('is-ready');
      resize();
    },
    undefined,
    () => {
      stageEl.classList.add('is-fallback');
    }
  );

  function frame(now) {
    rafId = requestAnimationFrame(frame);
    const dt = Math.min(0.05, Math.max(0.001, (now - lastTime) * 0.001));
    lastTime = now;

    const p = computeScrollProgress();
    updateChapterHud(p);
    const pose = samplePose(p);

    if (!isDragging) {
      dragYaw *= Math.exp(-1.5 * dt);
      dragPitch *= Math.exp(-1.7 * dt);
    }

    const alpha = reducedMotion ? 1 : 1 - Math.exp(-8.5 * dt);
    curRotY = lerp(curRotY, pose.rotY, alpha);
    curRotX = lerp(curRotX, pose.rotX, alpha);
    curRotZ = lerp(curRotZ, pose.rotZ, alpha);
    curY = lerp(curY, pose.y, alpha);
    curCamZ = lerp(curCamZ, pose.camZ, alpha);
    curHoverX = lerp(curHoverX, hoverX, alpha);
    curHoverY = lerp(curHoverY, hoverY, alpha);

    elapsed += dt;
    const swayY = reducedMotion ? 0 : Math.sin(elapsed * 1.45) * 0.032;
    const swayRotZ = reducedMotion ? 0 : Math.sin(elapsed * 1.1) * 0.03;

    if (loaded) {
      pivot.rotation.y = curRotY + dragYaw + curHoverX * 0.15;
      pivot.rotation.x = curRotX + dragPitch + curHoverY * 0.09;
      pivot.rotation.z = curRotZ + swayRotZ;
      pivot.position.y = curY + swayY;
      camera.position.z = curCamZ;
      renderer.render(scene, camera);
    }
  }

  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      cancelAnimationFrame(rafId);
      rafId = 0;
    } else if (!rafId) {
      lastTime = performance.now();
      rafId = requestAnimationFrame(frame);
    }
  });

  lastTime = performance.now();
  rafId = requestAnimationFrame(frame);
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initShowcase, { once: true });
} else {
  initShowcase();
}
