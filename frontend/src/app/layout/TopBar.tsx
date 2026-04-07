export default function TopBar() {
  return (
    <div className="topbar">
      <strong>AURION</strong>
      <span>Weather → Gas</span>
      <span>{new Date().toLocaleTimeString()}</span>
    </div>
  );
}