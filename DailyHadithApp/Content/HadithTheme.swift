import SwiftUI

struct HadithTheme: Identifiable, Hashable {
    let id: String
    let title: String
    let urduTitle: String
    let symbolName: String
}

enum ThemeCatalog {
    static let all: [HadithTheme] = [
        HadithTheme(id: "character", title: "Character", urduTitle: "کردار", symbolName: "person.crop.circle"),
        HadithTheme(id: "livelihood-charity", title: "Charity", urduTitle: "صدقہ", symbolName: "heart"),
        HadithTheme(id: "family-community", title: "Community", urduTitle: "معاشرہ", symbolName: "person.2"),
        HadithTheme(id: "faith-trust", title: "Faith", urduTitle: "ایمان", symbolName: "sparkles"),
        HadithTheme(id: "mercy-repentance", title: "Mercy", urduTitle: "رحمت", symbolName: "leaf"),
        HadithTheme(id: "quran-dhikr", title: "Quran", urduTitle: "قرآن", symbolName: "book.closed"),
        HadithTheme(id: "ramadan-fasting", title: "Ramadan", urduTitle: "رمضان", symbolName: "moon.stars"),
        HadithTheme(id: "worship", title: "Worship", urduTitle: "عبادت", symbolName: "hands.sparkles"),
    ]

    static func theme(id: String?) -> HadithTheme? {
        guard let id else { return nil }
        return all.first { $0.id == id }
    }
}
