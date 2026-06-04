from app.weather import get_weather
from app.llm import get_recommendation


def main():
    print("Personal Weather Assistant")
    print("Type 'exit' to quit.\n")

    while True:
        city = input("City: ").strip()

        if city.lower() == "exit":
            break

        date = input("Date YYYY-MM-DD: ").strip()

        try:
            weather = get_weather(city, date)
            recommendation = get_recommendation(weather)

            print("\n--- Recommendation ---")
            print(recommendation)
            print()

        except Exception as e:
            print(f"Error: {e}\n")


if __name__ == "__main__":
    main()
    