import { useState } from "react";
import "./App.css";

const API = process.env.REACT_APP_API_URL || "http://localhost:8000";

export default function App() {
  const [mode, setMode] = useState("signin"); // "signin" | "signup" | "dashboard"
  const [form, setForm] = useState({ name: "", email: "", password: "" });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [user, setUser] = useState(null);

  const handle = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
    setError("");
  };

  const submit = async (endpoint) => {
    setLoading(true);
    setError("");
    try {
      const body = endpoint === "signup"
        ? { name: form.name, email: form.email, password: form.password }
        : { email: form.email, password: form.password };

      const res = await fetch(`${API}/${endpoint}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });

      const data = await res.json();

      if (!res.ok) {
        setError(data.message || "Something went wrong.");
      } else {
        localStorage.setItem("token", data.token);
        setUser(data.user);
        setMode("dashboard");
      }
    } catch {
      setError("Cannot connect to server. Make sure the backend is running.");
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    localStorage.removeItem("token");
    setUser(null);
    setForm({ name: "", email: "", password: "" });
    setMode("signin");
  };

  if (mode === "dashboard") {
    return (
      <div className="page">
        <div className="card dashboard-card">
          <div className="avatar">{user?.name?.[0]?.toUpperCase()}</div>
          <h2 className="welcome">Welcome back,</h2>
          <h1 className="user-name">{user?.name}</h1>
          <p className="user-email">{user?.email}</p>
          <div className="badge">✓ Authenticated</div>
          <button className="btn btn-outline" onClick={logout}>Sign Out</button>
        </div>
      </div>
    );
  }

  return (
    <div className="page">
      <div className="card">
        <div className="logo">⬡</div>
        <h1 className="brand">Vault</h1>
        <p className="tagline">Secure authentication, simply done.</p>

        <div className="tabs">
          <button
            className={`tab ${mode === "signin" ? "active" : ""}`}
            onClick={() => { setMode("signin"); setError(""); }}
          >Sign In</button>
          <button
            className={`tab ${mode === "signup" ? "active" : ""}`}
            onClick={() => { setMode("signup"); setError(""); }}
          >Sign Up</button>
        </div>

        <div className="form">
          {mode === "signup" && (
            <div className="field">
              <label>Full Name</label>
              <input
                name="name"
                placeholder="John Doe"
                value={form.name}
                onChange={handle}
                autoComplete="name"
              />
            </div>
          )}

          <div className="field">
            <label>Email</label>
            <input
              name="email"
              type="email"
              placeholder="you@example.com"
              value={form.email}
              onChange={handle}
              autoComplete="email"
            />
          </div>

          <div className="field">
            <label>Password</label>
            <input
              name="password"
              type="password"
              placeholder={mode === "signup" ? "Min. 6 characters" : "Your password"}
              value={form.password}
              onChange={handle}
              autoComplete={mode === "signup" ? "new-password" : "current-password"}
            />
          </div>

          {error && <div className="error">{error}</div>}

          <button
            className="btn btn-primary"
            onClick={() => submit(mode)}
            disabled={loading}
          >
            {loading ? <span className="spinner" /> : mode === "signin" ? "Sign In" : "Create Account"}
          </button>
        </div>

        <p className="switch">
          {mode === "signin" ? "Don't have an account?" : "Already have an account?"}{" "}
          <button
            className="link"
            onClick={() => { setMode(mode === "signin" ? "signup" : "signin"); setError(""); }}
          >
            {mode === "signin" ? "Sign up" : "Sign in"}
          </button>
        </p>
      </div>
    </div>
  );
}
