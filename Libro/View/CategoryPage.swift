//
//  CategoryPage.swift
//  Libro
//
//  Created by Rana on 06/12/1447 AH.
//

import SwiftUI

// MARK: - Category View

struct CategoryView: View {

    @State private var selectedCategories: Set<String> = []

    let onContinue: () -> Void

    let categories = [
        "Fantasy", "Psychology", "Self-Help",
        "Health & Fitness", "Historical Fiction",
        "Adventure", "Romance", "Politics",
        "Science", "Business & Entrepreneurship",
        "Art & Design"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Title
            Text("What do you like to read?")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color("darkbrown"))
                .padding(.horizontal, 24)
                .padding(.top, 52)

            // MARK: Subtitle
            Text("Lorem ipsum dolor sit amet. Consectetur adipiscing elit.")
                .font(.system(size: 15))
                .foregroundColor(Color("gray"))
                .padding(.horizontal, 24)
                .padding(.top, 12)

            // MARK: Chips
            ChipFlow(
                categories: categories,
                selectedCategories: $selectedCategories
            )
            .padding(.horizontal, 24)
            .padding(.top, 32)

            Spacer()

            // MARK: Continue Button
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(
                        selectedCategories.isEmpty
                        ? Color("gray")
                        : .white
                    )
                    .frame(width: 320, height: 58)
                    .background(
                        selectedCategories.isEmpty
                        ? Color("lightGray")
                        : Color("buttons")
                    )
                    .clipShape(Capsule())
            }
            .disabled(selectedCategories.isEmpty)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 34)
            .animation(
                .spring(response: 0.3),
                value: selectedCategories.isEmpty
            )
        }
        .background(
            Color("background")
                .ignoresSafeArea()
        )
    }
}

// MARK: - Chip Flow

struct ChipFlow: View {

    let categories: [String]
    @Binding var selectedCategories: Set<String>

    var body: some View {
        GeometryReader { geo in

            let rows = makeRows(
                totalWidth: geo.size.width
            )

            VStack(
                alignment: .leading,
                spacing: 14
            ) {
                ForEach(rows.indices, id: \.self) { i in

                    HStack(spacing: 14) {

                        ForEach(rows[i], id: \.self) { category in

                            CategoryChip(
                                title: category,
                                isSelected: selectedCategories.contains(category)
                            ) {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(
            height:
                rowCount() * 48 +
                max(0, rowCount() - 1) * 14
        )
    }

    private func chipWidth(
        _ title: String
    ) -> CGFloat {

        let font = UIFont.systemFont(
            ofSize: 15
        )

        let textWidth =
        (title as NSString)
            .size(
                withAttributes: [
                    .font: font
                ]
            )
            .width

        return textWidth + 48
    }

    private func makeRows(
        totalWidth: CGFloat
    ) -> [[String]] {

        var rows: [[String]] = [[]]
        var rowWidth: CGFloat = 0

        for category in categories {

            let width = chipWidth(category)

            if rowWidth + width > totalWidth &&
                !rows.last!.isEmpty {

                rows.append([category])
                rowWidth = width + 14

            } else {

                rows[
                    rows.count - 1
                ]
                .append(category)

                rowWidth += width + 14
            }
        }

        return rows
    }

    private func rowCount() -> CGFloat {

        let screenWidth =
        UIScreen.main.bounds.width - 48

        return CGFloat(
            makeRows(
                totalWidth: screenWidth
            ).count
        )
    }
}

// MARK: - Category Chip

struct CategoryChip: View {

    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {

        Button(action: onTap) {

            Text(title)
                .font(
                    .system(
                        size: 15,
                        weight: isSelected
                        ? .semibold
                        : .regular
                    )
                )
                .foregroundColor(
                    isSelected
                    ? .white
                    : Color("darkbrown")
                )
                .padding(.horizontal, 24)
                .frame(height: 48)
                .background(
                    isSelected
                    ? Color("buttons")
                    : Color("background")
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected
                            ? Color.clear
                            : Color("darkbrown")
                                .opacity(0.25),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(
            .spring(response: 0.3),
            value: isSelected
        )
    }
}

#Preview {
    CategoryView {

    }
}
