import { useState, useEffect } from "react";

const GITHUB_URL = "https://github.com/chrisrogers37/im-not-talking-to-claude";
const RELEASES_URL = "https://github.com/chrisrogers37/im-not-talking-to-claude/releases";

// Color system
const C = {
  bg: "#0a0a0b",
  surface: "#141416",
  surfaceHover: "#1a1a1e",
  border: "rgba(255,255,255,0.06)",
  text: "#e8e8ed",
  muted: "#8b8b96",
  faint: "#5a5a66",
  exposed: "#ef4444",
  exposedSoft: "rgba(239,68,68,0.08)",
  exposedGlow: "0 0 30px rgba(239,68,68,0.15)",
  hidden: "#22c55e",
  hiddenSoft: "rgba(34,197,94,0.08)",
  hiddenGlow: "0 0 30px rgba(34,197,94,0.12)",
  accent: "#60a5fa",
};

export default function INTTCLanding() {
  const [isHidden, setIsHidden] = useState(false);
  const [showDropdown, setShowDropdown] = useState(true);
  const [suspendProcesses, setSuspendProcesses] = useState(false);
  const [showSessions, setShowSessions] = useState(true);
  const [hoverCTA, setHoverCTA] = useState(false);
  const [eyeBlink, setEyeBlink] = useState(false);

  // Blink the eye on toggle
  useEffect(() => {
    setEyeBlink(true);
    const t = setTimeout(() => setEyeBlink(false), 300);
    return () => clearTimeout(t);
  }, [isHidden]);

  const statusColor = isHidden ? C.hidden : C.exposed;
  const statusSoft = isHidden ? C.hiddenSoft : C.exposedSoft;
  const statusGlow = isHidden ? C.hiddenGlow : C.exposedGlow;

  const sessions = [
    { dir: "~/projects/benzo", terminal: "iTerm2", status: isHidden ? "hidden" : "running" },
    { dir: "~/projects/shuffify", terminal: "Warp", status: isHidden ? "hidden" : "running" },
    { dir: "~/projects/storyline-ai", terminal: "Ghostty", status: isHidden ? "hidden" : "running" },
  ];

  return (
    <div
      style={{
        minHeight: "100vh",
        background: C.bg,
        fontFamily: "'JetBrains Mono', 'SF Mono', 'Fira Code', monospace",
        color: C.text,
        overflowX: "hidden",
        position: "relative",
      }}
    >
      <link
        href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400&family=Space+Grotesk:wght@300;400;500;600;700&display=swap"
        rel="stylesheet"
      />
      <style>{`
        @media (max-width: 768px) {
          .inttc-header { padding: 20px 16px !important; }
          .inttc-hero { padding: 40px 16px 16px !important; }
          .inttc-section { padding-left: 16px !important; padding-right: 16px !important; }
          .inttc-grid-3 { grid-template-columns: 1fr !important; }
          .inttc-grid-features { grid-template-columns: 1fr !important; }
          .inttc-grid-terminals { grid-template-columns: repeat(2, 1fr) !important; }
          .inttc-mockup { max-width: 100% !important; }
          .inttc-footer { padding: 20px 16px !important; }
        }
      `}</style>

      {/* Ambient glow that shifts with state */}
      <div
        style={{
          position: "fixed",
          top: "-20%",
          left: "50%",
          transform: "translateX(-50%)",
          width: "80vw",
          height: "60vh",
          borderRadius: "50%",
          background: isHidden
            ? "radial-gradient(ellipse, rgba(34,197,94,0.04) 0%, transparent 70%)"
            : "radial-gradient(ellipse, rgba(239,68,68,0.04) 0%, transparent 70%)",
          pointerEvents: "none",
          transition: "background 1s ease",
          filter: "blur(80px)",
        }}
      />

      {/* Scan line effect */}
      <div
        style={{
          position: "fixed",
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background:
            "repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(255,255,255,0.008) 2px, rgba(255,255,255,0.008) 4px)",
          pointerEvents: "none",
          zIndex: 1,
        }}
      />

      {/* Header */}
      <header
        className="inttc-header"
        style={{
          padding: "28px 40px",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          position: "relative",
          zIndex: 10,
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <span style={{ fontSize: 20, transition: "transform 0.3s ease", transform: eyeBlink ? "scaleY(0.1)" : "scaleY(1)" }}>
            {isHidden ? "🫣" : "👁️"}
          </span>
          <span
            style={{
              fontSize: 12,
              fontWeight: 600,
              letterSpacing: "0.12em",
              textTransform: "uppercase",
              color: C.muted,
            }}
          >
            INTTC
          </span>
        </div>
        <div style={{ display: "flex", gap: 20, fontSize: 12 }}>
          <a
            href={GITHUB_URL}
            target="_blank"
            rel="noopener noreferrer"
            style={{ color: C.muted, textDecoration: "none", transition: "color 0.2s" }}
            onMouseEnter={e => e.currentTarget.style.color = C.text}
            onMouseLeave={e => e.currentTarget.style.color = C.muted}
          >
            GitHub
          </a>
          <a
            href={RELEASES_URL}
            target="_blank"
            rel="noopener noreferrer"
            style={{
              color: statusColor,
              textDecoration: "none",
              fontWeight: 500,
              transition: "color 0.4s",
            }}
          >
            Download
          </a>
        </div>
      </header>

      {/* Hero */}
      <section
        className="inttc-hero"
        style={{
          padding: "56px 40px 20px",
          maxWidth: 860,
          margin: "0 auto",
          textAlign: "center",
          position: "relative",
          zIndex: 10,
        }}
      >
        {/* Status badge */}
        <div
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 8,
            padding: "6px 16px",
            borderRadius: 100,
            background: statusSoft,
            border: `1px solid ${statusColor}22`,
            fontSize: 11,
            color: statusColor,
            marginBottom: 32,
            letterSpacing: "0.06em",
            fontWeight: 500,
            transition: "all 0.6s ease",
          }}
        >
          <span
            style={{
              width: 6,
              height: 6,
              borderRadius: "50%",
              background: statusColor,
              boxShadow: `0 0 8px ${statusColor}66`,
              transition: "all 0.4s ease",
            }}
          />
          {isHidden ? "CONCEALED" : "EXPOSED"}
        </div>

        <h1
          style={{
            fontFamily: "'Space Grotesk', sans-serif",
            fontSize: "clamp(28px, 6vw, 58px)",
            fontWeight: 300,
            lineHeight: 1.1,
            letterSpacing: "-0.03em",
            margin: "0 0 20px",
            color: C.text,
          }}
        >
          <span
            style={{
              display: "block",
              fontSize: "clamp(14px, 2.5vw, 20px)",
              fontWeight: 400,
              fontStyle: "italic",
              color: C.muted,
              letterSpacing: "0.01em",
              marginBottom: 6,
            }}
          >
            Babe,
          </span>
          I'm{" "}
          <em
            style={{
              fontStyle: "italic",
              fontWeight: 500,
              color: statusColor,
              transition: "color 0.6s ease",
            }}
          >
            not
          </em>{" "}
          talking
          <br />
          to Claude.
        </h1>

        <p
          style={{
            fontFamily: "'Space Grotesk', sans-serif",
            fontSize: 15,
            lineHeight: 1.7,
            color: C.muted,
            maxWidth: 480,
            margin: "0 auto 44px",
            fontWeight: 400,
          }}
        >
          One click hides every terminal running Claude Code.
          One click brings them all back. The alibi your git
          history can't provide.
        </p>

        {/* Keyboard shortcut hint */}
        <div
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 6,
            fontSize: 11,
            color: C.faint,
            marginBottom: 48,
          }}
        >
          <kbd
            style={{
              padding: "2px 7px",
              borderRadius: 4,
              background: C.surface,
              border: `1px solid ${C.border}`,
              fontSize: 10,
              color: C.muted,
            }}
          >
            ⌘
          </kbd>
          <kbd
            style={{
              padding: "2px 7px",
              borderRadius: 4,
              background: C.surface,
              border: `1px solid ${C.border}`,
              fontSize: 10,
              color: C.muted,
            }}
          >
            ⇧
          </kbd>
          <kbd
            style={{
              padding: "2px 7px",
              borderRadius: 4,
              background: C.surface,
              border: `1px solid ${C.border}`,
              fontSize: 10,
              color: C.muted,
            }}
          >
            H
          </kbd>
          <span style={{ marginLeft: 4 }}>to panic</span>
        </div>
      </section>

      {/* Menubar Mockup */}
      <section
        className="inttc-mockup"
        style={{
          maxWidth: 380,
          margin: "0 auto 40px",
          padding: "0 20px",
          position: "relative",
          zIndex: 10,
        }}
      >
        {/* Fake menubar */}
        <div
          style={{
            background: "#1c1c1e",
            borderRadius: "10px 10px 0 0",
            padding: "7px 14px",
            display: "flex",
            justifyContent: "flex-end",
            alignItems: "center",
            gap: 16,
            borderBottom: `1px solid ${C.border}`,
          }}
        >
          <span style={{ fontSize: 10, color: C.faint }}>Wi-Fi</span>
          <span style={{ fontSize: 10, color: C.faint }}>9:41 PM</span>
          <div
            onClick={() => setShowDropdown(!showDropdown)}
            style={{
              cursor: "pointer",
              padding: "2px 8px",
              borderRadius: 4,
              background: showDropdown ? statusSoft : "transparent",
              display: "flex",
              alignItems: "center",
              gap: 5,
              transition: "background 0.2s",
            }}
          >
            <span style={{ fontSize: 13, transition: "transform 0.3s", transform: eyeBlink ? "scaleY(0.1)" : "scaleY(1)" }}>
              {isHidden ? "🫣" : "👁️"}
            </span>
            <span
              style={{
                width: 5,
                height: 5,
                borderRadius: "50%",
                background: statusColor,
                boxShadow: `0 0 6px ${statusColor}55`,
                transition: "all 0.4s ease",
              }}
            />
          </div>
        </div>

        {/* Dropdown */}
        {showDropdown && (
          <div
            style={{
              background: "#1c1c1e",
              borderRadius: "0 0 10px 10px",
              border: `1px solid ${C.border}`,
              borderTop: "none",
              overflow: "hidden",
              boxShadow: `0 20px 60px rgba(0,0,0,0.5), ${statusGlow}`,
              transition: "box-shadow 0.6s ease",
            }}
          >
            {/* Master Toggle */}
            <div style={{ padding: "14px 18px", borderBottom: `1px solid ${C.border}` }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                <div>
                  <div style={{ fontSize: 12, fontWeight: 600, marginBottom: 3, fontFamily: "'Space Grotesk', sans-serif" }}>
                    {isHidden ? "Not Talking To Claude" : "Talking To Claude"}
                  </div>
                  <div style={{ fontSize: 10, color: C.muted, fontFamily: "'Space Grotesk', sans-serif" }}>
                    {isHidden
                      ? "Babe, never was. Nothing to see here."
                      : "3 sessions exposed. Everyone can see."}
                  </div>
                </div>

                {/* Toggle */}
                <div
                  onClick={() => setIsHidden(!isHidden)}
                  style={{
                    width: 44,
                    height: 24,
                    borderRadius: 12,
                    background: isHidden ? C.hidden : C.exposed,
                    cursor: "pointer",
                    position: "relative",
                    transition: "all 0.3s ease",
                    boxShadow: `0 0 12px ${statusColor}33`,
                    flexShrink: 0,
                  }}
                >
                  <div
                    style={{
                      width: 18,
                      height: 18,
                      borderRadius: "50%",
                      background: "#fff",
                      position: "absolute",
                      top: 3,
                      left: isHidden ? 23 : 3,
                      transition: "left 0.2s ease",
                      boxShadow: "0 1px 3px rgba(0,0,0,0.3)",
                    }}
                  />
                </div>
              </div>
            </div>

            {/* Sessions */}
            <div
              onClick={() => setShowSessions(!showSessions)}
              style={{
                padding: "8px 18px",
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
                cursor: "pointer",
                borderBottom: `1px solid ${C.border}`,
              }}
            >
              <span style={{ fontSize: 10, fontWeight: 500, color: C.muted, textTransform: "uppercase", letterSpacing: "0.08em" }}>
                Sessions
              </span>
              <span
                style={{
                  fontSize: 9,
                  color: C.faint,
                  transform: showSessions ? "rotate(90deg)" : "rotate(0deg)",
                  transition: "transform 0.2s",
                }}
              >
                ▶
              </span>
            </div>

            {showSessions && (
              <div>
                {sessions.map((s, i) => (
                  <div
                    key={i}
                    style={{
                      padding: "8px 18px",
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                      transition: "background 0.15s",
                    }}
                    onMouseEnter={e => e.currentTarget.style.background = C.surfaceHover}
                    onMouseLeave={e => e.currentTarget.style.background = "transparent"}
                  >
                    <div style={{ display: "flex", alignItems: "center", gap: 10, minWidth: 0 }}>
                      <span style={{ fontSize: 11, color: C.text, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>
                        {s.dir}
                      </span>
                    </div>
                    <div style={{ display: "flex", alignItems: "center", gap: 8, flexShrink: 0 }}>
                      <span style={{ fontSize: 9.5, color: C.faint, fontFamily: "'Space Grotesk', sans-serif" }}>{s.terminal}</span>
                      <span
                        style={{
                          width: 5,
                          height: 5,
                          borderRadius: "50%",
                          background: isHidden ? C.hidden : C.exposed,
                          boxShadow: `0 0 4px ${statusColor}44`,
                          transition: "all 0.3s",
                        }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Options */}
            <div style={{ borderTop: `1px solid ${C.border}`, padding: "10px 18px" }}>
              <div
                onClick={() => setSuspendProcesses(!suspendProcesses)}
                style={{
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                  cursor: "pointer",
                  marginBottom: 6,
                }}
              >
                <span style={{ fontSize: 10.5, color: C.muted, fontFamily: "'Space Grotesk', sans-serif" }}>
                  Kill Claude processes on hide
                </span>
                <div
                  style={{
                    width: 13,
                    height: 13,
                    borderRadius: 3,
                    border: suspendProcesses ? "none" : `1.5px solid ${C.faint}`,
                    background: suspendProcesses ? C.accent : "transparent",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontSize: 8,
                    color: "#fff",
                    transition: "all 0.2s",
                    flexShrink: 0,
                  }}
                >
                  {suspendProcesses && "✓"}
                </div>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 6, fontSize: 10, color: C.faint }}>
                <span>⌘⇧H</span>
                <span style={{ fontFamily: "'Space Grotesk', sans-serif" }}>Toggle shortcut</span>
              </div>
            </div>

            {/* Footer */}
            <div
              style={{
                padding: "8px 18px",
                borderTop: `1px solid ${C.border}`,
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}
            >
              <span style={{ fontSize: 9, color: C.faint }}>v0.2.0</span>
              <div style={{ display: "flex", gap: 12 }}>
                <span style={{ fontSize: 9, color: C.faint, cursor: "pointer" }}>Launch at Login</span>
                <span style={{ fontSize: 9, color: C.faint, cursor: "pointer" }}>Quit</span>
              </div>
            </div>
          </div>
        )}
      </section>

      {/* Scroll affordance */}
      <div style={{ textAlign: "center", margin: "0 auto 36px", position: "relative", zIndex: 10 }}>
        <div
          style={{
            display: "inline-block",
            animation: "gentleBounce 2.4s ease-in-out infinite",
            color: C.faint,
            fontSize: 18,
          }}
        >
          &#8964;
        </div>
        <style>{`
          @keyframes gentleBounce {
            0%, 100% { transform: translateY(0); opacity: 0.3; }
            50% { transform: translateY(6px); opacity: 0.6; }
          }
        `}</style>
      </div>

      {/* How It Works */}
      <section
        className="inttc-section"
        style={{
          maxWidth: 760,
          margin: "0 auto 56px",
          padding: "0 40px",
          position: "relative",
          zIndex: 10,
        }}
      >
        <div
          style={{
            fontSize: 10,
            color: C.faint,
            textTransform: "uppercase",
            letterSpacing: "0.12em",
            marginBottom: 20,
            fontWeight: 500,
            textAlign: "center",
          }}
        >
          How it works
        </div>
        <div
          className="inttc-grid-3"
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(3, 1fr)",
            gap: 16,
          }}
        >
          {[
            {
              step: "01",
              title: "Detect",
              body: "Scans for claude processes across Terminal, iTerm2, Warp, Kitty, Alacritty, and Ghostty.",
            },
            {
              step: "02",
              title: "Hide",
              body: "One click hides all Claude terminal windows. Optionally freezes the processes too.",
            },
            {
              step: "03",
              title: "Restore",
              body: "Brings every window back exactly where it was. Same position, same size, same desktop.",
            },
          ].map((item, i) => (
            <div
              key={i}
              style={{
                background: C.surface,
                border: `1px solid ${C.border}`,
                borderRadius: 8,
                padding: "20px 16px",
                transition: "border-color 0.3s, box-shadow 0.3s",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.borderColor = `${statusColor}33`;
                e.currentTarget.style.boxShadow = `0 4px 20px ${statusColor}08`;
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.borderColor = C.border;
                e.currentTarget.style.boxShadow = "none";
              }}
            >
              <div
                style={{
                  fontSize: 28,
                  fontWeight: 700,
                  color: statusColor,
                  transition: "color 0.4s",
                  marginBottom: 8,
                  opacity: 0.4,
                  fontFamily: "'Space Grotesk', sans-serif",
                }}
              >
                {item.step}
              </div>
              <div
                style={{
                  fontSize: 13,
                  fontWeight: 600,
                  marginBottom: 6,
                  fontFamily: "'Space Grotesk', sans-serif",
                }}
              >
                {item.title}
              </div>
              <div style={{ fontSize: 11, color: C.muted, lineHeight: 1.6, fontFamily: "'Space Grotesk', sans-serif" }}>
                {item.body}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Feature grid */}
      <section
        className="inttc-section"
        style={{
          maxWidth: 760,
          margin: "0 auto 56px",
          padding: "0 40px",
          position: "relative",
          zIndex: 10,
        }}
      >
        <div
          className="inttc-grid-features"
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
            gap: 12,
          }}
        >
          {[
            {
              title: "Sub-second panic",
              body: "⌘⇧H and every Claude window vanishes. Faster than alt-tab. Faster than minimizing. Faster than closing the lid.",
            },
            {
              title: "Every terminal",
              body: "Terminal.app, iTerm2, Warp, Kitty, Alacritty, Ghostty. If you can run Claude Code in it, we can hide it.",
            },
            {
              title: "Perfect recall",
              body: "Windows come back exactly where they were. Same position. Same size. Same virtual desktop. Like nothing happened.",
            },
            {
              title: "Kill on hide",
              body: "Optionally terminate Claude processes when hiding. Clean shutdown via SIGTERM. No evidence left behind.",
            },
            {
              title: "Session catalog",
              body: "See every active Claude session — working directory, terminal, status. Trust but verify.",
            },
            {
              title: "Free & open source",
              body: "MIT licensed. No telemetry. Your conversations with Claude are nobody's business.",
            },
          ].map((card, i) => (
            <div
              key={i}
              style={{
                background: C.surface,
                border: `1px solid ${C.border}`,
                borderRadius: 8,
                padding: "18px 16px",
                transition: "border-color 0.3s, box-shadow 0.3s",
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.borderColor = `${statusColor}33`;
                e.currentTarget.style.boxShadow = `0 4px 20px ${statusColor}08`;
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.borderColor = C.border;
                e.currentTarget.style.boxShadow = "none";
              }}
            >
              <div
                style={{
                  fontSize: 12,
                  fontWeight: 600,
                  marginBottom: 6,
                  fontFamily: "'Space Grotesk', sans-serif",
                }}
              >
                {card.title}
              </div>
              <div style={{ fontSize: 11, color: C.muted, lineHeight: 1.6, fontFamily: "'Space Grotesk', sans-serif" }}>
                {card.body}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Terminal support */}
      <section
        className="inttc-section"
        style={{
          maxWidth: 540,
          margin: "0 auto 56px",
          padding: "0 40px",
          position: "relative",
          zIndex: 10,
        }}
      >
        <div
          style={{
            background: C.surface,
            border: `1px solid ${C.border}`,
            borderRadius: 8,
            padding: 20,
          }}
        >
          <div
            style={{
              fontSize: 10,
              color: C.faint,
              textTransform: "uppercase",
              letterSpacing: "0.1em",
              marginBottom: 14,
              fontWeight: 500,
            }}
          >
            Supported terminals
          </div>
          <div
            className="inttc-grid-terminals"
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(3, 1fr)",
              gap: 8,
            }}
          >
            {["Terminal.app", "iTerm2", "Warp", "Kitty", "Alacritty", "Ghostty"].map((t) => (
              <div
                key={t}
                style={{
                  padding: "8px 12px",
                  borderRadius: 6,
                  background: C.bg,
                  border: `1px solid ${C.border}`,
                  fontSize: 11,
                  color: C.muted,
                  textAlign: "center",
                  fontFamily: "'Space Grotesk', sans-serif",
                }}
              >
                {t}
              </div>
            ))}
          </div>
          <div style={{ fontSize: 10, color: C.faint, marginTop: 12, textAlign: "center", fontFamily: "'Space Grotesk', sans-serif" }}>
            macOS Ventura and later · No special permissions required
          </div>
        </div>
      </section>

      {/* The joke section */}
      <section
        className="inttc-section"
        style={{
          maxWidth: 540,
          margin: "0 auto 56px",
          padding: "0 40px",
          position: "relative",
          zIndex: 10,
          textAlign: "center",
        }}
      >
        <div
          style={{
            background: C.surface,
            border: `1px solid ${C.border}`,
            borderRadius: 8,
            padding: "24px 20px",
          }}
        >
          <div style={{ fontSize: 10, color: C.faint, textTransform: "uppercase", letterSpacing: "0.1em", marginBottom: 14, fontWeight: 500 }}>
            Frequently anticipated objections
          </div>
          <div style={{ fontFamily: "'Space Grotesk', sans-serif", fontSize: 12, color: C.muted, lineHeight: 2 }}>
            <p style={{ margin: "0 0 12px" }}>
              <span style={{ color: C.text, fontWeight: 500 }}>"Is this a real product?"</span>
              <br />
              Yes. It hides your Claude terminals. That's it.
            </p>
            <p style={{ margin: "0 0 12px" }}>
              <span style={{ color: C.text, fontWeight: 500 }}>"Can't I just minimize the windows?"</span>
              <br />
              Sure. All 7 of them. One by one. While someone watches.
            </p>
            <p style={{ margin: "0 0 12px" }}>
              <span style={{ color: C.text, fontWeight: 500 }}>"Why does it say 'Babe'?"</span>
              <br />
              You know why.
            </p>
            <p style={{ margin: 0 }}>
              <span style={{ color: C.text, fontWeight: 500 }}>"Did Claude write this app?"</span>
              <br />
              Babe, I'm not talking to Claude.
            </p>
          </div>
        </div>
      </section>

      {/* CTA */}
      <section
        className="inttc-section"
        style={{
          maxWidth: 540,
          margin: "0 auto 56px",
          padding: "0 40px",
          textAlign: "center",
          position: "relative",
          zIndex: 10,
        }}
      >
        <a
          href={RELEASES_URL}
          target="_blank"
          rel="noopener noreferrer"
          style={{ textDecoration: "none" }}
        >
          <button
            onMouseEnter={() => setHoverCTA(true)}
            onMouseLeave={() => setHoverCTA(false)}
            style={{
              padding: "14px 36px",
              borderRadius: 8,
              border: `1px solid ${statusColor}66`,
              background: hoverCTA ? statusSoft : "transparent",
              color: statusColor,
              fontSize: 13,
              fontWeight: 600,
              fontFamily: "'JetBrains Mono', monospace",
              letterSpacing: "0.04em",
              cursor: "pointer",
              transition: "all 0.3s ease",
              boxShadow: hoverCTA ? statusGlow : "none",
            }}
          >
            Download INTTC
          </button>
        </a>
        <div style={{ marginTop: 14 }}>
          <a
            href={GITHUB_URL}
            target="_blank"
            rel="noopener noreferrer"
            style={{ fontSize: 11, color: C.muted, textDecoration: "none" }}
          >
            View on GitHub →
          </a>
        </div>
      </section>

      {/* Domain joke */}
      <section
        className="inttc-section"
        style={{
          maxWidth: 540,
          margin: "0 auto 40px",
          padding: "0 40px",
          textAlign: "center",
          position: "relative",
          zIndex: 10,
        }}
      >
        <div style={{ fontSize: 10, color: C.faint, fontFamily: "'Space Grotesk', sans-serif" }}>
          The full name is "Babe, I'm Not Talking To Claude."
          <br />
          Yes, it's a mouthful. That's the point.
        </div>
      </section>

      {/* Footer */}
      <footer
        className="inttc-footer"
        style={{
          padding: "28px 40px",
          textAlign: "center",
          position: "relative",
          zIndex: 10,
          borderTop: `1px solid ${C.border}`,
        }}
      >
        <div style={{ fontSize: 10, color: C.faint, lineHeight: 1.8, fontFamily: "'Space Grotesk', sans-serif" }}>
          MIT License ·{" "}
          <a
            href={GITHUB_URL}
            target="_blank"
            rel="noopener noreferrer"
            style={{ color: C.muted, textDecoration: "none" }}
          >
            Source on GitHub
          </a>
        </div>
      </footer>
    </div>
  );
}
