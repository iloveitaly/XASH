#define OPEN_URL(urlString) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]]

static inline BOOL isEmpty(id thing) {
    return thing == nil
	|| ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}