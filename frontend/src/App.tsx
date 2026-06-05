import { useState } from "react";
import "./App.css";

const API_URL = import.meta.env.VITE_API_URL || "";

type WeatherData = {
  city: string;
  date: string;
  min_temp: number;
  max_temp: number;
  weather: string[];
};

type ApiResponse = {
  weather: WeatherData;
  recommendation: string;
};


function App() {
  const [city, setCity] = useState("Zagreb");
  const [date, setDate] = useState("");
  const [result, setResult] = useState<ApiResponse | null>(null);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault();

    setLoading(true);
    setError("");
    setResult(null);

    try {
      const response = await fetch(`${API_URL}/api/recommendation`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          city,
          date,
        }),
      });

      if (!response.ok) {
        throw new Error("Failed to get recommendation");
      }

      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError("Something went wrong. Check backend, API keys, city, or date.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="app">
      <header className="topbar">
        <div>
          <h1>Personal Weather Assistant</h1>
          <p>Weather data + AI recommendations</p>
        </div>
      </header>

      <main className="main">
        <section className="card">
          <div className="card-header">
            <h2>Check your day</h2>
            <p>Enter city and date. Use a date within the next 5 days.</p>
          </div>

          <form onSubmit={handleSubmit} className="form">
            <label>
              City
              <input
                value={city}
                onChange={(event) => setCity(event.target.value)}
                placeholder="Zagreb"
              />
            </label>

            <label>
              Date
              <input
                type="date"
                value={date}
                onChange={(event) => setDate(event.target.value)}
              />
            </label>

            <button disabled={loading || !city || !date}>
              {loading ? "Thinking..." : "Get recommendation"}
            </button>
          </form>

          {error && <div className="error">{error}</div>}

          {result && (
            <div className="result">
              <div className="weather-box">
                <h3>
                  {result.weather.city} — {result.weather.date}
                </h3>

                <p>
                  Temperature: {result.weather.min_temp.toFixed(1)}°C —{" "}
                  {result.weather.max_temp.toFixed(1)}°C
                </p>

                <p>
                  Conditions:{" "}
                  {[...new Set(result.weather.weather)].join(", ")}
                </p>
              </div>

              <div className="recommendation">
                <h3>AI Recommendation</h3>
                <pre>{result.recommendation}</pre>
              </div>
            </div>
          )}
        </section>
      </main>
    </div>
  );
}

export default App;
