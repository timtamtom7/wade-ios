import Foundation

// MARK: - Shared Trip Models

struct SharedTrip: Identifiable, Codable {
    let id: UUID
    let tripId: UUID
    var shareLink: String
    var sharedWith: [String]
    var permissions: SharePermission
    var comments: [TripComment]
    var versionHistory: [TripVersion]
    var createdAt: Date

    var hasEditablePermission: Bool {
        permissions == .edit || permissions == .admin
    }
}

struct TripComment: Identifiable, Codable {
    let id: UUID
    let authorId: String
    let authorName: String
    let content: String
    let activityId: UUID?
    let timestamp: Date
}

struct TripVersion: Identifiable, Codable {
    let id: UUID
    let authorId: String
    let authorName: String
    let timestamp: Date
    let changesSummary: String
    let snapshotData: Data?
}

enum SharePermission: String, Codable {
    case viewOnly
    case comment
    case edit
    case admin
}

// MARK: - Buddy Match Models

struct BuddyMatch: Identifiable, Codable {
    let id: UUID
    let userId: String
    let userName: String
    let destination: String
    let travelDates: DateInterval
    let travelStyle: TravelStyle
    let compatibilityScore: Double
    let mutualContacts: Int
    var connectionStatus: ConnectionStatus
}

enum ConnectionStatus: String, Codable {
    case pending
    case connected
    case declined
}

// MARK: - Group Planning Models

struct GroupPlan: Identifiable, Codable {
    let id: UUID
    let tripId: UUID
    var members: [GroupMember]
    var expenses: [GroupExpense]
    var votes: [GroupVote]
    var designatedOrganizer: String?
}

struct GroupMember: Identifiable, Codable {
    let id: UUID
    let userId: String
    let userName: String
    var role: MemberRole
    var avatarInitials: String
}

enum MemberRole: String, Codable {
    case organizer
    case editor
    case viewer
}

struct GroupExpense: Identifiable, Codable {
    let id: UUID
    let paidBy: String
    let paidByName: String
    let amount: Double
    let currency: String
    let description: String
    let splitType: SplitType
    let splitAmong: [String]
    let date: Date
}

enum SplitType: String, Codable, CaseIterable {
    case equal
    case exact
    case percentage
    case shares
}

struct GroupVote: Identifiable, Codable {
    let id: UUID
    let question: String
    var options: [VoteOption]
    var votedBy: [String]
    var closedAt: Date?
    var status: VoteStatus

    var winningOption: VoteOption? {
        guard status == .closed, !options.isEmpty else { return nil }
        return options.max(by: { $0.votes < $1.votes })
    }
}

struct VoteOption: Identifiable, Codable {
    let id: UUID
    let text: String
    var votes: Int
}

enum VoteStatus: String, Codable {
    case open
    case closed
}

// MARK: - TravelSocialService

final class TravelSocialService: @unchecked Sendable {
    static let shared = TravelSocialService()

    private let userId = UUID().uuidString

    // MARK: - Shared Itineraries

    /// Share a trip itinerary with specific friends via generated link
    func shareItinerary(tripId: UUID, withFriends friendEmails: [String]) -> SharedTrip {
        let shareLink = generateShareLink(for: tripId)

        let sharedTrip = SharedTrip(
            id: UUID(),
            tripId: tripId,
            shareLink: shareLink,
            sharedWith: friendEmails,
            permissions: .edit,
            comments: [],
            versionHistory: [],
            createdAt: Date()
        )

        return sharedTrip
    }

    /// Get all trips shared with the current user
    func getSharedTrips() -> [SharedTrip] {
        // In production, fetch from Supabase
        return sampleSharedTrips()
    }

    /// Start collaborating on a shared trip
    func collaborateOnTrip(tripId: UUID) {
        // In production: connect to Supabase Realtime channel for this trip
    }

    /// Add a comment to a shared itinerary
    func addComment(to tripId: UUID, text: String, activityId: UUID?) -> TripComment {
        TripComment(
            id: UUID(),
            authorId: userId,
            authorName: "You",
            content: text,
            activityId: activityId,
            timestamp: Date()
        )
    }

    // MARK: - Travel Buddies

    /// Find people traveling to overlapping destinations
    func findTravelBuddies(destination: String, startDate: Date, endDate: Date) -> [BuddyMatch] {
        // In production: query Supabase for matching trips
        return sampleBuddyMatches(for: destination)
    }

    /// Connect with a travel buddy
    func connectWithBuddy(buddyId: UUID) {
        // In production: update connection status in Supabase
    }

    /// Get all buddy matches for current user
    func getAllBuddyMatches() -> [BuddyMatch] {
        return sampleBuddyMatches(for: "Tokyo")
    }

    // MARK: - Group Planning

    /// Create or get group plan for a trip
    func getOrCreateGroupPlan(for tripId: UUID) -> GroupPlan {
        GroupPlan(
            id: UUID(),
            tripId: tripId,
            members: sampleGroupMembers(),
            expenses: [],
            votes: [],
            designatedOrganizer: userId
        )
    }

    /// Add an expense to group plan
    func addExpense(to plan: inout GroupPlan, expense: GroupExpense) {
        plan.expenses.append(expense)
    }

    /// Create a vote in group plan
    func createVote(in plan: inout GroupPlan, question: String, options: [String]) -> GroupVote {
        let vote = GroupVote(
            id: UUID(),
            question: question,
            options: options.map { VoteOption(id: UUID(), text: $0, votes: 0) },
            votedBy: [],
            closedAt: nil,
            status: .open
        )
        plan.votes.append(vote)
        return vote
    }

    /// Cast a vote
    func castVote(in plan: inout GroupPlan, voteId: UUID, optionId: UUID) {
        guard let voteIndex = plan.votes.firstIndex(where: { $0.id == voteId }),
              !plan.votes[voteIndex].votedBy.contains(userId) else { return }

        plan.votes[voteIndex].votedBy.append(userId)

        if let optIndex = plan.votes[voteIndex].options.firstIndex(where: { $0.id == optionId }) {
            plan.votes[voteIndex].options[optIndex].votes += 1
        }
    }

    /// Close a vote and determine winner
    func closeVote(in plan: inout GroupPlan, voteId: UUID) {
        guard let idx = plan.votes.firstIndex(where: { $0.id == voteId }) else { return }
        plan.votes[idx].status = .closed
        plan.votes[idx].closedAt = Date()
    }

    /// Calculate expense splits
    func calculateSplits(for plan: GroupPlan) -> [String: Double] {
        var balances: [String: Double] = [:]

        for member in plan.members {
            balances[member.userId] = 0
        }

        for expense in plan.expenses {
            let splitCount: Double
            let splitAmount: Double

            switch expense.splitType {
            case .equal:
                splitCount = Double(expense.splitAmong.count)
                splitAmount = expense.amount / splitCount
                balances[expense.paidBy, default: 0] += expense.amount
                for userId in expense.splitAmong {
                    balances[userId, default: 0] -= splitAmount
                }

            case .exact, .percentage, .shares:
                // For non-equal splits, just credit the payer
                balances[expense.paidBy, default: 0] += expense.amount
            }
        }

        return balances
    }

    // MARK: - Private Helpers

    private func generateShareLink(for tripId: UUID) -> String {
        let token = UUID().uuidString.prefix(12)
        return "https://wade.app/share/\(token)"
    }

    private func sampleSharedTrips() -> [SharedTrip] {
        [
            SharedTrip(
                id: UUID(),
                tripId: UUID(),
                shareLink: "https://wade.app/share/abc123",
                sharedWith: ["alex@email.com", "sam@email.com"],
                permissions: .edit,
                comments: [
                    TripComment(
                        id: UUID(),
                        authorId: "user1",
                        authorName: "Alex",
                        content: "Should we skip the museum? Line was 2 hours last week.",
                        activityId: nil,
                        timestamp: Date().addingTimeInterval(-3600)
                    )
                ],
                versionHistory: [],
                createdAt: Date().addingTimeInterval(-86400)
            )
        ]
    }

    private func sampleBuddyMatches(for destination: String) -> [BuddyMatch] {
        [
            BuddyMatch(
                id: UUID(),
                userId: "buddy1",
                userName: "Sarah M.",
                destination: destination,
                travelDates: DateInterval(start: Date(), duration: 86400 * 5),
                travelStyle: .adventure,
                compatibilityScore: 0.85,
                mutualContacts: 3,
                connectionStatus: .pending
            ),
            BuddyMatch(
                id: UUID(),
                userId: "buddy2",
                userName: "James K.",
                destination: destination,
                travelDates: DateInterval(start: Date(), duration: 86400 * 7),
                travelStyle: .luxury,
                compatibilityScore: 0.72,
                mutualContacts: 1,
                connectionStatus: .pending
            )
        ]
    }

    private func sampleGroupMembers() -> [GroupMember] {
        [
            GroupMember(id: UUID(), userId: userId, userName: "You", role: .organizer, avatarInitials: "YO"),
            GroupMember(id: UUID(), userId: "member2", userName: "Alex", role: .editor, avatarInitials: "AL"),
            GroupMember(id: UUID(), userId: "member3", userName: "Sam", role: .editor, avatarInitials: "SA"),
        ]
    }
}
