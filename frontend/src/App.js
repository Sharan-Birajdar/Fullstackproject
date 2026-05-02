import { useState } from "react";

const API = process.env.REACT_APP_API_URL;

function App() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const signup = async () => {
    const res = await fetch(`${API}/signup`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password })
    });
    const data = await res.json();
    alert(data.message);
  };

  const signin = async () => {
    const res = await fetch(`${API}/signin`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password })
    });
    const data = await res.json();
    alert(data.message);
  };

  return (
    <div style={{ padding: 20 }}>
      <h2>Auth App</h2>
      <input placeholder="Email" onChange={(e) => setEmail(e.target.value)} />
      <br /><br />
      <input type="password" placeholder="Password" onChange={(e) => setPassword(e.target.value)} />
      <br /><br />
      <button onClick={signup}>Signup</button>
      <button onClick={signin}>Signin</button>
    </div>
  );
}

export default App;
