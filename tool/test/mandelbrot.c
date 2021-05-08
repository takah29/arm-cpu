int main() {
    const float CENTER_X = -0.5;
    const float CENTER_Y = 0.0;
    const float SCALE_X = 2.0;
    const float SCALE_Y = 2.0;
    const int X_SIZE = 2;
    const int Y_SIZE = 2;

    int image[Y_SIZE][X_SIZE];
    float y = 0, x = 0;

    y = CENTER_Y + SCALE_Y / 2.0;
    for (int i = 0; i < Y_SIZE; i++) {
        y -= SCALE_Y / Y_SIZE;
        x = CENTER_X + SCALE_X / 2.0;
        for (int j = 0; j < X_SIZE; j++) {
            x += SCALE_X / X_SIZE;
            float z1 = 0.0, z2 = 0.0;
            for (int n = 1; n < 1000; n++) {
                z1 = z1 * z1 - z2 * z2 + x;
                z2 = 2 * z1 * z2 + y;
                if (z1 * z1 + z2 * z2 > 2.0) {
                    image[i][j] = 255;
                }
            }
            image[i][j] = 0;
        }
    }

    return 0;
}
