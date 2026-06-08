import { useState } from "react";
import "./App.css";

// const API_URL = import.meta.env.VITE_API_URL || "";
// const API_URL = "http://localhost:8000";

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

type CitySuggestion = {
  name: string;
  country: string;
  state?: string;
  lat: number;
  lon: number;
  label: string;
};



function App() {
  const [city, setCity] = useState("Zagreb");
  const [date, setDate] = useState("");
  const [note, setNote] = useState("");
  const [result, setResult] = useState<ApiResponse | null>(null);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [citySuggestions, setCitySuggestions] = useState<CitySuggestion[]>([]);

  
  /**
   * Handle city input change, update city state and fetch city suggestions if input length is sufficient.
   */
  async function handleCityChange(value: string) {
    setCity(value);

    if (value.length < 2) {
      setCitySuggestions([]);
      return;
    }

    try {
      const response = await fetch(
        `/api/cities?q=${encodeURIComponent(value)}`
      );

      if (!response.ok) {
        return;
      }

      const data = await response.json();
      setCitySuggestions(data);
    } catch {
      setCitySuggestions([]);
    }
  }


  /**
   * Handle form submission, send a POST request to the backend with city, date, and note, and update the result or error state based on the response.
   */
  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault();

    setLoading(true);
    setError("");
    setResult(null);

    try {
      const response = await fetch(`/api/recommendation`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          city,
          date,
          note,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => null);
        throw new Error(
          errorData?.detail || "No weather information available for this request."
        );
      }

      const data = await response.json();
      setResult(data);
    } catch (err) {
      setError(
        err instanceof Error
          ? err.message
          : "No weather information available for this request."
      );
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
                onChange={(event) => handleCityChange(event.target.value)}
                placeholder="Zagreb"
                list="city-suggestions"
              />

              <datalist id="city-suggestions">
                {citySuggestions.map((item) => (
                  <option key={`${item.lat}-${item.lon}`} value={item.label} />
                ))}
              </datalist>
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

            <label className="note-field">
              Custom note <span className="optional">(optional)</span>
              <textarea
                value={note}
                onChange={(event) => setNote(event.target.value)}
                placeholder="Example: I'm going hiking, I have a business meeting, I will walk a lot..."
              />
            </label>
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
