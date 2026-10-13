def main():
    project_name = "Construction Material Demand & Procurement Forecasting"

    materials = [
        "Cement",
        "Steel",
        "Sand",
        "Aggregates",
        "Bricks",
    ]

    print("=" * 60)
    print(project_name)
    print("=" * 60)

    print("\nMaterials to be analyzed:")
    for material in materials:
        print(f"- {material}")

    print("\nEnvironment setup successful!")


if __name__ == "__main__":
    main()