import type { PlanePoint } from '../types';

interface CreatePlaneElementArgs {
  plane: PlanePoint;
  onHover: (plane: PlanePoint) => void;
  onLeave: (plane: PlanePoint) => void;
  onClick: (plane: PlanePoint) => void;
}

export function createPlaneElement({
  plane,
  onHover,
  onLeave,
  onClick,
}: CreatePlaneElementArgs): HTMLElement {
  const el = document.createElement('div');

  const rawHeading = Number(plane.bearing_deg ?? plane.heading_deg);
  const heading = Number.isFinite(rawHeading) ? rawHeading : 0;

  el.innerHTML = `
    <div style="
      width: 16px;
      height: 16px;
      display: flex;
      align-items: center;
      justify-content: center;
      transform: rotate(${heading}deg);
      transform-origin: center center;
    ">
      <svg width="16" height="16" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" style="display:block;">
        <path d="M32 2 L38 22 L58 28 L58 34 L38 36 L35 62 L29 62 L26 36 L6 34 L6 28 L26 22 Z" fill="${plane.color}" />
        <path d="M28 30 L10 39 L10 44 L28 40 Z" fill="${plane.color}" />
        <path d="M36 30 L54 39 L54 44 L36 40 Z" fill="${plane.color}" />
        <path d="M29 8 L35 8 L34 18 L30 18 Z" fill="#dbeafe" opacity="0.9" />
      </svg>
    </div>
  `;

  el.style.cursor = 'pointer';
  el.style.pointerEvents = 'auto';
  el.style.userSelect = 'none';
  el.style.lineHeight = '1';

  el.onmouseenter = () => onHover(plane);
  el.onmouseleave = () => onLeave(plane);
  el.onclick = () => onClick(plane);

  return el;
}