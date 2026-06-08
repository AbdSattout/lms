package app.lms.block.controller;

import app.lms.block.dto.*;
import app.lms.block.mapper.BlockMapper;
import app.lms.block.model.Block;
import app.lms.block.service.BlockAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/blocks")
@RequiredArgsConstructor
public class BlockController {

    private final BlockAccessService blockAccessService;
    private final BlockMapper blockMapper;

    @GetMapping("/{blockId}")
    public BlockPublicResponse getBlock(
            @PathVariable Long blockId,
            @AuthenticationPrincipal User user
    ) {
        Block block = blockAccessService.getAccessibleBlock(blockId, user);
        return blockMapper.toPublicResponse(block);
    }
}
