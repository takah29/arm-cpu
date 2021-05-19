import numpy as np
import math
import matplotlib.pyplot as plt

center = (-0.5, 0)
scale = (2.0, 2.0)


def mandelbrot(x, y):
    z1, z2 = 0, 0
    for n in range(1, 20):
        z1, z2 = z1 * z1 - z2 * z2 + x, 2 * z1 * z2 + y
        if (z1 * z1 + z2 * z2) > 4.0:
            return n

    return 0


def calc_image(x_size, y_size):
    image = np.zeros((y_size, x_size), dtype=np.float32)

    y = center[1] + scale[1] / 2.0
    dy = scale[1] / y_size
    for i in range(y_size):
        y -= dy
        x = center[0] - scale[0] / 2.0
        dx = scale[0] / x_size
        for j in range(x_size):
            x += dx
            image[i, j] = mandelbrot(x, y)

    return image


def main():
    image = calc_image(10, 10)
    plt.imshow(image, cmap="gray")
    plt.show()


if __name__ == "__main__":
    main()
