import Foundation
import Supabase

class SupabaseClient {
    static let shared = SupabaseClient()

    let client: Supabase.SupabaseClient

    private init() {
        self.client = Supabase.SupabaseClient(
            supabaseURL: URL(string: "https://wnznhkimziiojltrxmnr.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Induem5oa2ltemlpb2psdHJ4bW5yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1OTI5NTksImV4cCI6MjA4MDE2ODk1OX0.PK6aL7Titlha61Ymos1K5E7eiSLN1ot181tTrsH-VEU"
        )
    }
}
