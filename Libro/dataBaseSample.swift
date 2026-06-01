//
//  ContentView.swift
//  Libro
//
//  Created by Wareef Saeed Alzahrani on 06/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
// هي البوابة بين التطبيق وقاعدة البيانات (SwiftData)
//كل عمليات الحفظ، الإضافة، الحذف، التعديل تمر من هنا
    @Environment(\.modelContext) private var modelContext
    
// @Query نستخدمها عشان نسحب البيانات من الداتا بس ونعرضها
// يمدينا نسوي لها سورت عشان تنعرض لنا مرتبة (شيكوا على الفيديو ٥:٤٩)
    @Query private var users : [User]
    
    
// @State نستخدمها عشان ناخذ البيانات من اليوزر بالواجهات وتحفظها بالداتا بيس
    // هنا عرفنا متغيرات عشان نسحب المعلومات من اليوزر
    @State private var username: String = ""
    @State private var userstreak: Int = 0
    @State private var userIcon: String = ""


    var body: some View {
 TextField("Add Item", text: $username) //
        TextField("Add Item", text: $userIcon)
        
        
        // هنا شغل الحفظ كامل بعد مايضغط اليوزر على البوتون
        Button("Add Item") {
            let newUser =  User(userName: username, userIcon: userIcon, streak: 3) //هنا يحفظ بينات اليوزر داخل متغير
            
            
           
            
            let newbook =  Book(bookName: "Book", bookImage: "Book", bookGoal: "5 pages", reflection: "I'm reading", bookRate: 4.5, status: "finished")
            
            newUser.books?.append(newbook)
            modelContext.insert(newUser)

            //مو تأكدين بس غالبا تتعامل مع المشاكل و الاخطاء بس الافضل نضيفها
            try? modelContext.save()
            username = ""
            userIcon = ""
            userstreak = 0
            
        }
        
        Divider()
        
        // هذي ليست عشان نعرض الداتا عالشاشة
        List(users) { user in
            Text("\(user.userName)")
            Text("\(user.userIcon)")
            Text("\(user.streak)")
            Text("\(user.id)")
            
            ForEach(user.books ?? []) { book in
                 Text(book.bookName ?? "")
             }

            


            

            
        }
    }

  

}

#Preview {
    ContentView()
        .modelContainer(for: User.self, inMemory: true)
}
