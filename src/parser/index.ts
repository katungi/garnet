import { join } from "https://deno.land/std@0.224.0/path/mod.ts";

async function parse(): Promise<void> {
  try {
    const filePath = join(Deno.cwd(), "src/parser/sample.gt");
    console.log("Parsing file at:", filePath);

    const fileContents = await Deno.readFile(filePath);

    const decodedContents = new TextDecoder().decode(fileContents);

    console.log("File Contents:\n", decodedContents);
  } catch (error) {
    console.error("Error reading the file:", error.message);
  }
}

parse();
