enum LibraryLoadState: Equatable {
    case loading
    case loaded(LibrarySnapshot)
    case failed(String)
}
