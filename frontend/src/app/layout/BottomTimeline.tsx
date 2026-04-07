export default function BottomTimeline() {
  return (
    <div className="timeline">
      <div className="timeline__header">
        <strong>Timeline</strong>
        <span>Last 7 days</span>
      </div>

      <input type="range" min="0" max="100" defaultValue="100" className="timeline__slider" />

      <div className="timeline__labels">
        <span>-7d</span>
        <span>Now</span>
      </div>
    </div>
  );
}