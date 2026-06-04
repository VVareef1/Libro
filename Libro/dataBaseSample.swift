//
//  ContentView1.swift
//  Libro

import SwiftUI
import SwiftData

struct ContentView1: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var username: String = ""
    @State private var userIcon: String = ""
    @State private var navigate = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("اسم المستخدم", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                TextField("أيقونة المستخدم", text: $userIcon)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                // زر السامبل كتب
                Button("Add Sample Books") {
                    let book1 = Book(bookName: "فن اللامبالاة", bookImage: "book2", bookGoal: "10 pages", reflection: "كتاب رائع", bookRate: 4.5, status: "finished")
                    let book2 = Book(bookName: "قصة الفن", bookImage: "book1", bookGoal: "5 pages", reflection: "ممتع", bookRate: 4.0, status: "finished")
                    let book3 = Book(bookName: "Atomic Habits", bookImage: "book2", bookGoal: "15 pages", reflection: "مفيد جداً", bookRate: 5.0, status: "finished")
                    
                    modelContext.insert(book1)
                    modelContext.insert(book2)
                    modelContext.insert(book3)
                    try? modelContext.save()
                    
                    
                    let s1 = Session(timer: 0, date: makeDate(12, 1, 2026), duration: 1800, stoppedPage: 12, quote: "Lorem ipsum dolor sit amet. Consectetur adipiscing elit.", quotePageNumber: 12)
                    let s2 = Session(timer: 0, date: makeDate(12, 1, 2026), duration: 1800, stoppedPage: 20, quote: "Consectetur adipiscing elit Lorem ipsum dolor sit amet.", quotePageNumber: 20)
                    let s3 = Session(timer: 0, date: makeDate(10, 1, 2026), duration: 1800, stoppedPage: 35, quote: "Lorem ipsum dolor sit amet consectetur.", quotePageNumber: 35)
                    let s4 = Session(timer: 0, date: makeDate(2, 1, 2026), duration: 1800, stoppedPage: 50, quote: "Adipiscing elit sed do eiusmod tempor.", quotePageNumber: 50)

                    s1.book = book1
                    s2.book = book1
                    s3.book = book1
                    s4.book = book1

                    modelContext.insert(s1)
                    modelContext.insert(s2)
                    modelContext.insert(s3)
                    modelContext.insert(s4)
                    
                
                    
                }
                .padding()
                
                
                NavigationLink(destination: LibraryView()) {
                    Text("اذهب للمكتبة")
                }
                
                
                Button("حذف كل البيانات") {
                    try? modelContext.delete(model: Book.self)
                    try? modelContext.delete(model: User.self)
                }
                
                // زر إضافة يوزر
                Button("Add Item") {
                    let newUser = User(userName: username, userIcon: userIcon, streak: 3)
                    let newBook = Book(bookName: "Book", bookImage: "Book", bookGoal: "5 pages", reflection: "I'm reading", bookRate: 4.5, status: "finished")
                    
                    newUser.books?.append(newBook)
                    modelContext.insert(newUser)
                    try? modelContext.save()
                    
                    username = ""
                    userIcon = ""
                }
                .padding()
                
                Divider()
                
                // عرض البيانات
                List(users) { user in
                    VStack(alignment: .leading) {
                        Text(user.userName ?? "")
                        Text(user.userIcon ?? "")
                        Text("\(user.streak ?? 0)")
                        Text(user.id.uuidString)
                        
                        ForEach(user.books ?? []) { book in
                            Text(book.bookName ?? "")
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigate) {
                LibraryView()
            }
        }
    }
    
    func makeDate(_ day: Int, _ month: Int, _ year: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? .now
    }
    
}

#Preview {
    ContentView1()
        .modelContainer(for: [User.self, Book.self], inMemory: true)
}
