import Foundation
import CoreData

class CommunityViewModel: ObservableObject {
    @Published var events: [CommunityEvent] = []
    @Published var posts: [CommunityPost] = []
    
    private let context = CoreDataManager.shared.context
    
    init() {
        fetchEvents()
        fetchPosts()
    }
    
    private func fetchEvents() {
        let request: NSFetchRequest<CDCommunityEvent> = CDCommunityEvent.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDCommunityEvent.date, ascending: true)]
        
        do {
            let cdEvents = try context.fetch(request)
            events = cdEvents.map { CommunityEvent(from: $0) }
        } catch {
            print("Error fetching events: \(error)")
        }
    }
    
    private func fetchPosts() {
        let request: NSFetchRequest<CDCommunityPost> = CDCommunityPost.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDCommunityPost.timestamp, ascending: false)]
        
        do {
            let cdPosts = try context.fetch(request)
            posts = cdPosts.map { CommunityPost(from: $0) }
        } catch {
            print("Error fetching posts: \(error)")
        }
    }
    
    func addEvent(_ event: CommunityEvent) {
        let cdEvent = CDCommunityEvent(context: context)
        cdEvent.id = event.id
        cdEvent.title = event.title
        cdEvent.descriptionText = event.description
        cdEvent.date = event.date
        cdEvent.location = event.location
        cdEvent.imageURL = event.imageURL
        
        CoreDataManager.shared.save()
        fetchEvents()
    }
    
    func addPost(_ post: CommunityPost) {
        let cdPost = CDCommunityPost(context: context)
        cdPost.id = post.id
        cdPost.authorName = post.authorName
        cdPost.authorImageURL = post.authorImageURL
        cdPost.content = post.content
        cdPost.timestamp = post.timestamp
        cdPost.likes = Int32(post.likes)
        
        CoreDataManager.shared.save()
        fetchPosts()
    }
    
    func addComment(_ comment: CommunityPost.Comment, to postId: UUID) {
        guard let cdPost = try? context.fetch(CDCommunityPost.fetchRequest()).first(where: { $0.id == postId }) else {
            return
        }
        
        let cdComment = CDComment(context: context)
        cdComment.id = comment.id
        cdComment.authorName = comment.authorName
        cdComment.content = comment.content
        cdComment.timestamp = comment.timestamp
        cdComment.post = cdPost
        
        CoreDataManager.shared.save()
        fetchPosts()
    }
    
    func updateLikes(for postId: UUID, newCount: Int) {
        guard let cdPost = try? context.fetch(CDCommunityPost.fetchRequest()).first(where: { $0.id == postId }) else {
            return
        }
        
        cdPost.likes = Int32(newCount)
        CoreDataManager.shared.save()
        fetchPosts()
    }
}

// MARK: - Model Extensions
extension CommunityEvent {
    init(from cdEvent: CDCommunityEvent) {
        self.id = cdEvent.id ?? UUID()
        self.title = cdEvent.title ?? ""
        self.description = cdEvent.descriptionText ?? ""
        self.date = cdEvent.date ?? Date()
        self.location = cdEvent.location ?? ""
        self.imageURL = cdEvent.imageURL
    }
}

extension CommunityPost {
    init(from cdPost: CDCommunityPost) {
        self.id = cdPost.id ?? UUID()
        self.authorName = cdPost.authorName ?? ""
        self.authorImageURL = cdPost.authorImageURL
        self.content = cdPost.content ?? ""
        self.timestamp = cdPost.timestamp ?? Date()
        self.likes = Int(cdPost.likes)
        self.comments = (cdPost.comments?.allObjects as? [CDComment])?.map { Comment(from: $0) } ?? []
    }
}

extension CommunityPost.Comment {
    init(from cdComment: CDComment) {
        self.id = cdComment.id ?? UUID()
        self.authorName = cdComment.authorName ?? ""
        self.content = cdComment.content ?? ""
        self.timestamp = cdComment.timestamp ?? Date()
    }
} 