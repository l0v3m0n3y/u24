# u24
web api for u24.gov.ua Ukraine's official fundraising platform, launched by President @zelenskyy_official. Support Ukraine
# main
```swift
import Foundation
import u24

let u24Cli = U24()
let projects = try await u24Cli.getCategoryList(category: "projects",page: 1,pageSize: 12,directionId: 0)
print(projects)
```

# Launch (your script)
```
swift run
```
