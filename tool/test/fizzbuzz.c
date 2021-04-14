int main() {
    int i;
    int ret[50];
    for (i = 1; i < 50; i++) {
        if (i % 15 == 0) {
            ret[i] = 3;
        } else if (i % 5 == 0) {
            ret[i] = 2;
        } else if (i % 3 == 0) {
            ret[i] = 1;
        } else {
            ret[i] = 0;
        }
    }
    return 0;
}
