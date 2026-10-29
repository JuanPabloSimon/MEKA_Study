import fs from "node:fs";
import path from "node:path";
import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { App } from "./App";
import { STRINGS } from "./strings";

const ROOT_DIR = path.resolve(import.meta.dirname, "../..");

function readJsonFile(relativePath: string): Record<string, unknown> {
  const raw = fs.readFileSync(path.join(ROOT_DIR, relativePath), "utf8");
  const stripped = raw.replace(/\/\*[\s\S]*?\*\/|^\s*\/\/.*$/gm, "");
  return JSON.parse(stripped) as Record<string, unknown>;
}

function collectSourceFiles(dirPath: string): string[] {
  if (!fs.existsSync(dirPath)) return [];
  const results: string[] = [];
  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    const fullPath = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      results.push(...collectSourceFiles(fullPath));
    } else if (/\.(ts|tsx)$/.test(entry.name)) {
      results.push(fullPath);
    }
  }
  return results;
}

describe("project_scaffold", () => {
  it("[project_scaffold R1] define los scripts lint, typecheck, test, build y verify en package.json y base '/' en vite.config.ts", () => {
    const pkg = readJsonFile("package.json");
    const scripts = pkg["scripts"] as Record<string, string> | undefined;

    expect(scripts).toBeDefined();
    expect(scripts?.["lint"]).toEqual(expect.any(String));
    expect(scripts?.["typecheck"]).toEqual(expect.any(String));
    expect(scripts?.["test"]).toEqual(expect.any(String));
    expect(scripts?.["build"]).toEqual(expect.any(String));
    expect(scripts?.["verify"]).toBe(
      "npm run lint && npm run typecheck && npm run test && npm run build",
    );

    const viteConfig = fs.readFileSync(
      path.join(ROOT_DIR, "vite.config.ts"),
      "utf8",
    );
    expect(viteConfig).toMatch(/base:\s*["']\/["']/);
  });

  it("[project_scaffold R2] exige strict: true y noUncheckedIndexedAccess: true en tsconfig.app.json y tsconfig.node.json", () => {
    for (const configFile of ["tsconfig.app.json", "tsconfig.node.json"]) {
      const tsconfig = readJsonFile(configFile);
      const compilerOptions = tsconfig["compilerOptions"] as
        Record<string, unknown> | undefined;

      expect(compilerOptions, `${configFile} compilerOptions`).toBeDefined();
      expect(compilerOptions?.["strict"], `${configFile} strict`).toBe(true);
      expect(
        compilerOptions?.["noUncheckedIndexedAccess"],
        `${configFile} noUncheckedIndexedAccess`,
      ).toBe(true);
    }
  });

  it("[project_scaffold R3] organiza src/ en las cinco capas con index.ts y mantiene aisladas las capas puras", () => {
    const layers = ["engine", "metrics", "text", "storage", "ui"] as const;
    for (const layer of layers) {
      const indexPath = path.join(ROOT_DIR, "src", layer, "index.ts");
      expect(
        fs.existsSync(indexPath),
        `Debe existir src/${layer}/index.ts`,
      ).toBe(true);
    }

    const pureLayers = ["engine", "metrics", "text"] as const;
    const forbiddenImports =
      /from\s+["'](?:\.\.?\/)*(?:ui|storage)(?:\/|["'])|from\s+["']react(?:-dom)?(?:\/|["'])/;
    const forbiddenDomGlobals = /\b(?:window|document|localStorage)\b/;

    for (const layer of pureLayers) {
      const files = collectSourceFiles(path.join(ROOT_DIR, "src", layer));
      expect(files.length).toBeGreaterThan(0);
      for (const file of files) {
        const content = fs.readFileSync(file, "utf8");
        expect(
          content,
          `${file} no debe importar ui/storage/react`,
        ).not.toMatch(forbiddenImports);
        expect(content, `${file} no debe usar globals del DOM`).not.toMatch(
          forbiddenDomGlobals,
        );
      }
    }
  });

  it("[project_scaffold R4] centraliza los textos visibles iniciales en src/ui/strings.ts con marca y lema de MEKA", () => {
    expect(STRINGS.brandName).toBe("MEKA");
    expect(STRINGS.tagline).toBe("Estudia de manera práctica");
  });

  it("[project_scaffold R5] declara las variables CSS globales en tokens.css y carga las fuentes en index.html con lang='es-AR'", () => {
    const tokensPath = path.join(ROOT_DIR, "src/ui/styles/tokens.css");
    expect(fs.existsSync(tokensPath)).toBe(true);
    const tokensCss = fs.readFileSync(tokensPath, "utf8");

    expect(tokensCss).toMatch(/--color-text:\s*#F9F0F1/i);
    expect(tokensCss).toMatch(/--color-background:\s*#003052/i);
    expect(tokensCss).toMatch(/--color-border:\s*#000000/i);
    expect(tokensCss).toMatch(/--color-primary:\s*#D4F4DD/i);
    expect(tokensCss).toMatch(/--color-secondary:\s*#748CAB/i);
    expect(tokensCss).toMatch(/--color-error:\s*#9E1A30/i);
    expect(tokensCss).toMatch(/--font-heading:\s*["']Basic["']/);
    expect(tokensCss).toMatch(/--font-body:\s*["']Montserrat["']/);
    expect(tokensCss).toMatch(/--font-mono:\s*["']Roboto Mono["']/);
    expect(tokensCss).toMatch(/--space-base:\s*8px/);
    expect(tokensCss).toMatch(/--space-md:\s*16px/);
    expect(tokensCss).toMatch(/--space-lg:\s*32px/);
    expect(tokensCss).toMatch(/--radius-none:\s*0px/);

    const indexHtml = fs.readFileSync(
      path.join(ROOT_DIR, "index.html"),
      "utf8",
    );
    expect(indexHtml).toMatch(/<html[^>]*\blang=["']es-AR["']/);
    expect(indexHtml).toContain("Basic");
    expect(indexHtml).toContain("Montserrat");
    expect(indexHtml).toContain("Roboto+Mono");
    expect(indexHtml).toMatch(/300;400;500;600/);
  });

  it("[project_scaffold R6] renderiza el título MEKA y el lema 'Estudia de manera práctica' al montar App", () => {
    render(<App />);
    expect(
      screen.getByRole("heading", { level: 1, name: STRINGS.brandName }),
    ).toBeDefined();
    expect(screen.getByText(STRINGS.tagline)).toBeDefined();
  });
});
