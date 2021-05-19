int main() {
    int X_SIZE = 10;
    int Y_SIZE = 10;
    float image[Y_SIZE][X_SIZE];

    float CENTER_X = -0.5;
    float CENTER_Y = 0.0;
    float SCALE_X = 2.0;
    float SCALE_Y = 2.0;
    float y = 0, x = 0;

    y = CENTER_Y + SCALE_Y / 2.0;
    float dy = SCALE_Y / Y_SIZE;
    float max = 0;
    for (int i = 0; i < Y_SIZE; i++) {
        y -= dy;
        x = CENTER_X - SCALE_X / 2.0;
        float dx = SCALE_X / X_SIZE;
        for (int j = 0; j < X_SIZE; j++) {
            x += dx;
            image[i][j] = 0;
            float z1 = 0, z2 = 0, z1_ = 0, z2_ = 0;
            for (int n = 0; n < 20; n++) {
                z1_ = z1 * z1 - z2 * z2 + x;
                z2_ = 2 * z1 * z2 + y;
                if (z1_ * z1_ + z2_ * z2_ > 4.0) {
                    image[i][j] = n;
                    if (image[i][j] > max) {
                        max = image[i][j];
                    }
                    break;
                }
                z1 = z1_;
                z2 = z2_;
            }
        }
    }

    int image_[Y_SIZE][X_SIZE];
    for (int i = 0; i < Y_SIZE; i++) {
        for (int j = 0; j < X_SIZE; j++) {
            image_[i][j] = (int)((image[i][j] / max) * 255);
        }
    }

    return 0;
}
