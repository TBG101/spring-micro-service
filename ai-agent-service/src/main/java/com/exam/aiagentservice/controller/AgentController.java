package com.exam.aiagentservice.controller;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.mcp.SyncMcpToolCallbackProvider;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RestController
public class AgentController {
    private final ChatClient chatClient;

    public AgentController(ChatClient.Builder builder, ChatMemory chatMemory, SyncMcpToolCallbackProvider toolProvider) {
        this.chatClient = builder.defaultSystem("You are a helpful assistant. Use the available tools to answer questions about products and stock.").defaultAdvisors(MessageChatMemoryAdvisor.builder(chatMemory).build()).defaultToolCallbacks(toolProvider)
                .build();
    }

    @GetMapping("/chat")
    public Flux<String> chat(@RequestParam String message) {
        return chatClient.prompt().user(message).stream().content();
    }
}

