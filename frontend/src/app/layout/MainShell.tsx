import type { ReactNode } from 'react';

type MainShellProps = {
  left: ReactNode;
  center: ReactNode;
  right: ReactNode;
  bottom: ReactNode;
};

export default function MainShell({ left, center, right, bottom }: MainShellProps) {
  return (
    <div className="main-shell">
      <div className="main-shell__body">
        <aside className="panel panel--left">{left}</aside>
        <main className="panel panel--center">{center}</main>
        <aside className="panel panel--right">{right}</aside>
      </div>

      <div className="panel panel--bottom">{bottom}</div>
    </div>
  );
}