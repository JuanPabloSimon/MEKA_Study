import { expect, test } from "@playwright/test";

test("[project_scaffold R7] muestra la pantalla inicial con MEKA, el lema y los colores de fondo y texto del sistema de diseño", async ({
  page,
}) => {
  await page.goto("/");

  await expect(
    page.getByRole("heading", { level: 1, name: "MEKA" }),
  ).toBeVisible();
  await expect(page.getByText("Estudia de manera práctica")).toBeVisible();

  const tokens = await page.evaluate(() => {
    const rootStyles = window.getComputedStyle(document.documentElement);
    return {
      background: rootStyles.getPropertyValue("--color-background").trim(),
      text: rootStyles.getPropertyValue("--color-text").trim(),
    };
  });

  expect(tokens.background.toUpperCase()).toBe("#003052");
  expect(tokens.text.toUpperCase()).toBe("#F9F0F1");

  const body = page.locator("body");
  await expect(body).toHaveCSS("background-color", "rgb(0, 48, 82)");
  await expect(body).toHaveCSS("color", "rgb(249, 240, 241)");
});
