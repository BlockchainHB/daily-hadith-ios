import Foundation

enum PreviewFixtures {
    static let firstHadith = AudioHadith(
        id: "hadith-001",
        sequence: 1,
        audioFileName: "hadith-001.m4a",
        durationSeconds: 145,
        title: "Avoid Harmful Social Behaviors",
        titleUrdu: "نقصان دہ معاشرتی رویوں سے بچیں",
        summary: "A short summary of the guidance.",
        translation: "In this Hadith, the Prophet Muhammad (peace be upon him) forbade suspicion, spying, envy, hatred, and backbiting, and instructed believers to be brothers as servants of Allah.",
        uncertaintyNote: "",
        reviewStatus: "pass",
        reviewConfidence: "high",
        reviewIssues: []
    )

    static let longHadith = AudioHadith(
        id: "hadith-002",
        sequence: 2,
        audioFileName: "hadith-002.m4a",
        durationSeconds: 305,
        title: "Prophet's Truth Affirmed by Quranic Stories",
        titleUrdu: "قرآنی واقعات سے نبی کی سچائی",
        summary: "The Quran demonstrates the truth of revelation through unseen past events.",
        translation: String(repeating: "Allah sent guidance through revelation, and believers are urged to understand, act, and remain mindful of returning to Him. ", count: 8),
        uncertaintyNote: "",
        reviewStatus: "pass",
        reviewConfidence: "high",
        reviewIssues: []
    )

    static var snapshot: LibrarySnapshot {
        try! LibrarySnapshot(hadiths: [firstHadith, longHadith])
    }
}
