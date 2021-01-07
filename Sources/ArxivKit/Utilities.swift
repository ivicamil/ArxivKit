
public enum Utilities {
    
    /// Prints human-readable list of all subjects.
    public static func printSubjects() {
        Subjects.print()
    }
    
    /// Generates `Subjects` namespace enum and all the constants.
    public static func generateSubjectSwiftConstants() -> String {
        return Subjects.generateSwiftConstants()
    }
}

