#!/usr/bin/env node

import fsPromises from 'fs/promises';

/**
 * CLI tool for reading an input file and extracting OpenAI request: system, user and assistant proompts.
 *
 * Highlevel flow:
 * 1. parse command line arguments
 * 2. merge config in following order. Futher overwrites. Oreder: defaults, environment variable and arguments
 * 3. read given input file
 * 4. extract prompts in order: optional COMMENT, optional SYSTEM, required USER, optional PREFIX and optional ASSISTANT
 * 5. make http call using OpenAI API schema
 * 6. parse response and extract content
 * 7. write output to stdout or given output file
 *
 * RULES:
 * - use node js standart library
 * - use promise versions for http client call, file read and write
 */

// Parse arguments block
interface InstructLlmArgs {
    // required argument. Should be a readable file.
    promptFile: string;
    // optional. If empty output to stdout.
    outputFile: string;
    // default is LLM_API_KEY environment variable
    apiKey: string;
    // default is https://codestral.mistral.ai/v1/chat/completions
    apiUrl: string;
    // default is 0
    temperature: number;
    // default is '
    model: string;
    // default is 1000
    maxTokens: number;
    // default is 42
    seed: number;
    // include '# @ASSISTANT', default is false
    isIncludeAssistant: boolean;
}

/**
 * Parse arguments as long name options.
 * Merge with environment variables.
 * Use a default values if none.
 */
function parseArguments(args: Array<string>): InstructLlmArgs {
    const defaults: InstructLlmArgs = {
        promptFile: '',
        outputFile: '',
        apiKey: process.env.LLM_API_KEY || '',
        apiUrl: 'https://codestral.mistral.ai/v1/chat/completions',
        temperature: 0,
        model: 'codestral-latest',
        maxTokens: 1000,
        seed: 42,
        isIncludeAssistant: false,
    };
    const result: InstructLlmArgs = { ...defaults };
    for (let i = 2; i < args.length; i++) {
        const arg = args[i];
        if (arg.startsWith('--')) {
            const key = arg.substring(2);
            const value = args[i + 1];
            if (value && !value.startsWith('--')) {
                result[key] = value;
                i++;
            } else {
                result[key] = true;
            }
        }
    }
    return result;
}

// Prompt build block

interface PromptRawDataInteraction {
    // Each interactions starts with user request
    user: string;
    // Each interaction could have a prefix.
    prefix?: string;
    // When interaction is done it should contain a reponse
    assistan?: string;
}

interface PromptRawData {
    // optional system prompt
    system?: string;
    // required array of chat interactions
    interactions: Array<PromptRawDataInteraction>;
}

/**
Extract prompt from file content.
File has following structure:
```markdown
# @SYSTEM
Here a system prompt.
It could be multiline and even contain code.
# @USER
This block contains a user prompt.
It could be multiline as well.
# @PREFIX
This block is optional.
It could be multiline againg.
# @ASSISTANT
Hello, I'm a helpful assistant.
# @USER
Some next message.
```
It should be:
```json
{
    "system": "Here a system prompt.\n It could be multiline and even contain code.",
    "interactions": [{
        "user": "This block contains a user prompt.\n It could be multiline as well.",
        "prefix": "This block is optional.\n It could be multiline againg.",
        "assistant": "Hello, I'm a helpful assistant.
    }, {"user": "Some next message."}]
}
```
 */
async function parseFile(filepath: string): Promise<PromptRawData> {
    const interactions: Array<PromptRawDataInteraction> = [];
    const result: PromptRawData = { system: '', interactions, };
    let currentInteraction: PromptRawDataInteraction = { user: 'NOT_INITIAILZED', };

    const SYSTEM_PROMPT = "# @SYSTEM";
    const USER_PROMPT = "# @USER";
    const PREFIX_PROMPT = "# @PREFIX";
    const ASSISTANT_PROMPT = "# @ASSISTANT";

    const content = await fsPromises.readFile(filepath, 'utf8');
    const lines = content.split('\n');

    let currentState = '';
    // Loop each line and fill each field
    for (const line of lines) {
        if (line.startsWith(SYSTEM_PROMPT)) {
            currentState = 'system';
            continue;
        } else if (line.startsWith(USER_PROMPT)) {
            currentState = 'user';
            // initialize interaction and push to an array
            currentInteraction = { user: '', assistan: '', prefix: '', };
            interactions.push(currentInteraction);
            continue;
        } else if (line.startsWith(PREFIX_PROMPT)) {
            currentState = 'prefix';
            continue;
        } else if (line.startsWith(ASSISTANT_PROMPT)) {
            currentState = 'assistant';
            continue;
        }
        // if currentState is empty, skip the line
        if (!currentState) {
            continue;
        }
        if (currentState === 'system') {
            // if currentState is system, append to system
            result.system += line + '\n';
        } else if (currentState === 'user') {
            // if currentState is user, append to user
            currentInteraction.user += line + '\n';
        } else if (currentState === 'prefix') {
            // if currentState is prefix, append to prefix
            currentInteraction.prefix += line + '\n';
        } else if (currentState === 'assistant') {
            // if currentState is assistant, append to assistant
            currentInteraction.assistan += line + '\n';
        }
    }


    // remove blank spaces for system field if presented
    if (result.system) {
        result.system = result.system.trim();
    }
    // remove blank spaces for each interaction
    for (const interaction of interactions) {
        interaction.user = interaction.user.trim();
        if (interaction.prefix) {
            interaction.prefix = interaction.prefix.trim();
        }
        if (interaction.assistan) {
            interaction.assistan = interaction.assistan.trim();
        }
    }
   

    return result;

}

// OpenAI api block

interface OpenAIResponseUsage {
    // example: 109
    prompt_tokens: number;
    // example: 113
    total_tokens: number;
    // example: 4
    completion_tokens: number;
}

interface OpenAIResponseChoiceMessage {
    // example: "assistant", "system", "user"
    role: string;
    // example: "Let's break down"
    content: string;
    // DONT KNOW YET
    tool_calls: null,
}

interface OpenAIResponseChoice {
    // example: 0
    index: number;
    // example: "length", "stop"
    finish_reason: string,
    message: OpenAIResponseChoiceMessage;
}

interface OpenAIResponse {
    // example: "9fca2e1dfef547238a8e68970b624411"
    id: string;
    // example: 1757969130
    created: number;
    // example: "codestral-latest"
    model: string;
    // example: "chat.completion"
    object: string;
    usage: OpenAIResponseUsage;
    choices: Array<OpenAIResponseChoice>;
}

interface MessageRequest {
    // system, user or assistant for prefix
    role: string;
    // message content
    content: string;
    // prefix is true ONLY for prefix message, for anything else it's empty
    prefix?: boolean;
}

interface OpenAIRequest {
    model: string;
    temperature: number;
    max_tokens: number;
    // seed and random_seed is mutually exclusive. For mistral use random_seed, for others seed
    seed?: number;
    // copy of seed
    random_seed: number;
    // always false
    stream: boolean;
    // message order: system, user [, prefix]
    messages: Array<MessageRequest>;
}

/**
 * Generate messages for OpenAI api.
 * When interaction already has assistant response IGNORE prefix if any.
 */
function convertToRequest(args: InstructLlmArgs, prompts: PromptRawData): OpenAIRequest {
    const messages: Array<MessageRequest> = [];
    if (prompts.system) {
        messages.push({
            role: 'system',
            content: prompts.system,
        });
    }

    for (const interaction of prompts.interactions) {
        messages.push({
            role: 'user',
            content: interaction.user,
        });
        if (interaction.assistan) {
            messages.push({
                role: 'assistant',
                content: interaction.assistan,
            });
        } else if (interaction.prefix) {
            messages.push({
                role: 'assistant',
                content: interaction.prefix,
                prefix: true,
            });
        }
    }

    return {
        model: args.model,
        temperature: args.temperature,
        max_tokens: args.maxTokens,
        // seed: args.seed,
        random_seed: args.seed,
        stream: false,
        messages,
    };
}

/*
Make an http call using fetch and return content
 */
async function callLlm(args: InstructLlmArgs, request: OpenAIRequest): Promise<string> {
    const response = await fetch(args.apiUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': `Bearer ${args.apiKey}`,
        },
        body: JSON.stringify(request),
    });
    const data: OpenAIResponse = await response.json();
    // when content is not presented throw an error
    if (!data.choices || !data.choices[0] || !data.choices[0].message || !data.choices[0].message.content) {
        throw new Error('Error: content is not presented in response: ' + JSON.stringify(data));
    }
    const summarize = `input: ${data.usage.prompt_tokens} output: ${data.usage.completion_tokens} finish_reason: ${data.choices[0].finish_reason}`
    console.error(summarize);

    return data.choices[0].message.content;
}

/**
 * Print usage with long names, defaults and environment variable names.
 */
function printUsage() {
    console.log('Usage: instruct-llm [--help] --promptFile <file> [--outputFile <file>] [--apiKey <key>] [--apiUrl <url>] [--temperature <number>] [--model <model>] [--maxTokens <number>] [--seed <number>]');
    console.log('Environment variables:');
    console.log('  LLM_API_KEY - default API key');
    console.log('Defaults:');
    console.log('  apiUrl: https://codestral.mistral.ai/v1/chat/completions');
    console.log('  temperature: 0');
    console.log('  model: codestral-latest');
    console.log('  maxTokens: 1000');
    console.log('  seed: 42');
}

// Main use case
async function main(args: Array<string>) {
    // if args contain --help printUsage
    if (args.includes('--help')) {
        printUsage();
        return;
    }
    const parsedArgs = parseArguments(args);
    const filepath = parsedArgs.promptFile;

    // test filepath is presented
    if (!filepath) {
        console.error('Error: promptFile is required');
        printUsage();
        return;
    }

    // test file exist and readable using node js file io
    await fsPromises.access(filepath, fsPromises.constants.R_OK);
    const prompt = await parseFile(filepath);

    // test prompt is not empty
    if (0 === prompt.interactions.length || !prompt.interactions[0].user) {
        console.error('Error: prompt is empty');
        return;
    }

    // test last interaction HAS assistan
    if (prompt.interactions[prompt.interactions.length - 1].assistan) {
        console.error('Error: last interaction should not have assistant response');
        return;
    }

    const request = convertToRequest(parsedArgs, prompt);

    // test apiKey is presented
    if (!parsedArgs.apiKey) {
        console.error('Error: apiKey is required');
        printUsage();
        return;
    }
    const response = await callLlm(parsedArgs, request);
    // if outputFile is presented write to file, else print to stdout
    if (parsedArgs.outputFile) {
        await fsPromises.writeFile(parsedArgs.outputFile, response);
    } else {
        if (parsedArgs.isIncludeAssistant) {
            console.log('# @ASSISTANT')
        }
        console.log(response);
    }
}

// EXECUTION BLOCK
main(process.argv);
