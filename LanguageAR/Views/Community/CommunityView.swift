import SwiftUI

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var showingNewPost = false
    
    var body: some View {
        NavigationView {
            List {
                // Featured Events
                Section(header: Text("Featured Events")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.events) { event in
                                EventCard(event: event)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 200)
                }
                
                // Community Posts
                Section(header: Text("Community Posts")) {
                    ForEach(viewModel.posts) { post in
                        CommunityPostView(post: post)
                    }
                }
            }
            .navigationTitle("Community")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewPost = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPost) {
                NewPostView()
            }
        }
    }
}

struct EventCard: View {
    let event: CommunityEvent
    @State private var isSharePresented = false
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: event.imageURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 100)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            
            Button(action: { isSharePresented = true }) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
        .sheet(isPresented: $isSharePresented) {
            ShareSheet(activityItems: [ShareManager.shared.shareCommunityEvent(event)])
        }
    }
}

struct CommunityPostView: View {
    let post: CommunityPost
    @State private var isSharePresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: post.authorImageURL) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(post.authorName)
                        .font(.headline)
                    Text(post.timestamp.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(post.content)
                .font(.body)
            
            HStack {
                Button(action: { /* Like action */ }) {
                    Label("\(post.likes)", systemImage: "heart")
                }
                
                Spacer()
                
                Button(action: { /* Comment action */ }) {
                    Label("\(post.comments.count)", systemImage: "bubble.right")
                }
                
                Button(action: { isSharePresented = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $isSharePresented) {
            ShareSheet(activityItems: [ShareManager.shared.shareCommunityPost(post)])
        }
    }
} 