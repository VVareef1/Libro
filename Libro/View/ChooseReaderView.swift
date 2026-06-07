import SwiftUI
import PhotosUI

struct ChooseReaderView: View {
    @State private var name = ""
    @State private var navigateToHome = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: Image?

    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()

                VStack(spacing: 0) {

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color(.systemGray5))
                            Rectangle().fill(Color("darkbrown")).frame(width: geo.size.width * 0.75)
                        }
                        .frame(height: 4)
                        .clipShape(Capsule())
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Spacer().frame(height: 36)

                    Text("Choose a Reader")
                        .font(.custom("DMSerifDisplay-Regular", size: 28))
                        .bold()
                        .foregroundColor(Color("darkbrown"))

                    Spacer().frame(height: 40)

                    // Avatars
                    ZStack {
                        Circle().fill(Color(.systemGray4)).frame(width: 76, height: 76).offset(x: -76).opacity(0.7)
                        Circle().fill(Color(.systemGray4)).frame(width: 76, height: 76).offset(x: 76).opacity(0.7)

                        ZStack(alignment: .bottomTrailing) {
                            Group {
                                if let avatarImage {
                                    avatarImage
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Circle().fill(Color(.systemGray3))
                                }
                            }
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())

                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Circle().fill(Color("buttons")).frame(width: 30, height: 30)
                                    .overlay(Image(systemName: "plus").font(.system(size: 13, weight: .bold)).foregroundColor(.white))
                                    .overlay(Circle().stroke(Color("background"), lineWidth: 2))
                            }
                        }
                    }
                    .frame(height: 130)
                    .onChange(of: selectedPhoto) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                avatarImage = Image(uiImage: uiImage)
                            }
                        }
                    }

                    Spacer().frame(height: 24)

                    Text("Name")
                        .font(.custom("DMSerifDisplay-Regular", size: 22))
                        .bold()
                        .foregroundColor(Color("darkbrown"))

                    Spacer().frame(height: 16)

                    TextField("ex: Sally", text: $name)
                        .font(.system(size: 15))
                        .foregroundColor(Color("darkbrown"))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 15)
                        .background(Color("background"))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color("darkbrown").opacity(0.25), lineWidth: 1.5))
                        .padding(.horizontal, 24)

                    Spacer()

                    Button { navigateToHome = true } label: {
                        Text("Start")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(Capsule().fill(Color("buttons").opacity(name.isEmpty ? 0.4 : 1)))
                    }
                    .disabled(name.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                    // ← نمرر الصورة والاسم للهوم
                    .navigationDestination(isPresented: $navigateToHome) {
                        HomeView(avatarImage: avatarImage, userName: name)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview { ChooseReaderView() }
