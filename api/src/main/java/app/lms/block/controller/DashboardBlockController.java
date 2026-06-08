package app.lms.block.controller;

import app.lms.block.dto.BlockResponse;
import app.lms.block.dto.CreateBlockRequest;
import app.lms.block.dto.ReorderBlocksRequest;
import app.lms.block.dto.UpdateBlockRequest;
import app.lms.block.mapper.BlockMapper;
import app.lms.block.model.Block;
import app.lms.block.service.BlockService;
import app.lms.block.service.DashboardBlockAccessService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardBlockController {

    private final BlockService blockService;
    private final BlockMapper blockMapper;
    private final DashboardBlockAccessService dashboardBlockAccessService;

    @PostMapping("/lessons/{lessonId}/blocks")
    public ResponseEntity<BlockResponse> create(

            @PathVariable Long lessonId,

            @RequestBody
            @Valid
            CreateBlockRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        blockService.create(
                                lessonId,
                                request,
                                principal.user()
                        )
                );
    }

    @PatchMapping("/blocks/{blockId}")
    public ResponseEntity<BlockResponse> update(

            @PathVariable Long blockId,

            @RequestBody
            @Valid
            UpdateBlockRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                blockService.update(
                        blockId,
                        request,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/blocks/{blockId}")
    public ResponseEntity<Void> delete(

            @PathVariable Long blockId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        blockService.delete(
                blockId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @PatchMapping("/lessons/{lessonId}/blocks/reorder")
    public ResponseEntity<Void> reorder(

            @PathVariable Long lessonId,

            @RequestBody
            @Valid
            ReorderBlocksRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        blockService.reorder(
                lessonId,
                request,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @GetMapping("/blocks/{blockId}")
    public BlockResponse getBlockForAdmin(
            @PathVariable Long blockId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        Block block = dashboardBlockAccessService.getManageableBlock(blockId, principal.user());
        return blockMapper.toResponse(block);
    }
}
